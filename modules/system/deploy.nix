{
  nixos.base = {
    config,
    lib,
    pkgs,
    ...
  }: let
    keys = import ./_deploy_keys.nix;
    tailscaleCidr = "100.64.0.0/10,fd7a:115c:a1e0::/48";
    deployKeyLines =
      lib.mapAttrsToList (
        _name: key: ''from="${tailscaleCidr}" ${key}''
      )
      keys.deployKeys;

    ndeployScript = pkgs.writeShellScriptBin "ndeploy" ''
      set -euo pipefail

      if [ $# -lt 1 ]; then
        echo "Usage: ndeploy <switch|test|boot> [host]" >&2
        exit 1
      fi

      verb="$1"
      if [ "$verb" != "switch" ] && [ "$verb" != "test" ] && [ "$verb" != "boot" ]; then
        echo "Error: Unknown verb '$verb'. Must be switch, test, or boot." >&2
        exit 1
      fi

      cur="$(hostname)"
      target="''${2:-$cur}"

      reachable() {
        ssh -o BatchMode=yes -o ConnectTimeout=5 "root@$1" true 2>/dev/null
      }

      if [ "$target" = "$cur" ]; then
        echo "==> Deploying locally to $cur ($verb)..."
        git -C /etc/nixos add -A && nh os "$verb"
        # A switch on hyde brings castor along when it's online.
        if [ "$cur" = "hyde" ] && [ "$verb" = "switch" ]; then
          # Syncthing keeps castor's /etc/nixos mirrored (system/syncthing.nix).
          if reachable castor; then
            echo "==> Deploying hyde's build to castor ($verb)..."
            nh os "$verb" --hostname castor --target-host "root@castor"
          else
            echo "==> castor is offline; skipped. Run 'nr castor' once it's back."
          fi
        fi
        exit 0
      fi

      echo "==> Preflight: Checking reachability of root@$target via Tailscale..."
      if ! reachable "$target"; then
        echo "Error: Cannot connect to root@$target via deploy key." >&2
        echo "Ensure Tailscale is connected and ~/.ssh/deploy_ed25519 is loaded." >&2
        exit 1
      fi

      if [ -n "$(git -C /etc/nixos status --porcelain 2>/dev/null)" ]; then
        echo "Warning: /etc/nixos has uncommitted changes." >&2
      fi

      if [ "$cur" = "hyde" ]; then
        echo "==> Deploying from hyde to $target (building on hyde, activating on $target)..."
        git -C /etc/nixos add -A && nh os "$verb" --hostname "$target" --target-host "root@$target"
      elif [ "$target" = "hyde" ]; then
        echo "==> Deploying from $cur to hyde (building and activating on hyde)..."
        git -C /etc/nixos add -A && nh os "$verb" --hostname hyde --build-host "root@hyde" --target-host "root@hyde"
      else
        echo "Error: Unsupported target host $target from $cur. Hyde is the build host." >&2
        exit 1
      fi
    '';

    nrScript = pkgs.writeShellScriptBin "nr" ''
      exec ${ndeployScript}/bin/ndeploy switch "$@"
    '';
    nbootScript = pkgs.writeShellScriptBin "nboot" ''
      exec ${ndeployScript}/bin/ndeploy boot "$@"
    '';
    ntestScript = pkgs.writeShellScriptBin "ntest" ''
      exec ${ndeployScript}/bin/ndeploy test "$@"
    '';
    ntryScript = pkgs.writeShellScriptBin "ntry" ''
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: ntry <package> [args...]" >&2
        exit 1
      fi
      pkg="$1"
      shift
      exec nix run "nixpkgs#$pkg" -- "$@"
    '';
    nshellScript = pkgs.writeShellScriptBin "nshell" ''
      set -euo pipefail
      if [ $# -lt 1 ]; then
        echo "Usage: nshell <packages...>" >&2
        exit 1
      fi
      args=()
      for p in "$@"; do
        args+=("nixpkgs#$p")
      done
      exec nix shell "''${args[@]}"
    '';
  in {
    assertions = [
      {
        assertion = !lib.hasInfix "AAAA..." (builtins.toJSON keys);
        message = "Deploy keys in _deploy_keys.nix must contain real keys, not placeholders.";
      }
      {
        assertion = !config.services.openssh.openFirewall;
        message =
          "services.openssh.openFirewall must be false; "
          + "sshd is exposed only on tailscale0.";
      }
      {
        assertion = config.services.openssh.settings.PasswordAuthentication == false;
        message = "sshd PasswordAuthentication must be false.";
      }
      {
        assertion =
          lib.all (
            k: lib.hasPrefix "from=" k
          )
          config.users.users.root.openssh.authorizedKeys.keys;
        message = "Every root authorized key must contain a from= restriction.";
      }
    ];

    services.tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "none";
    };

    services.openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "prohibit-password";
        AllowUsers = ["root"];
        X11Forwarding = false;
      };
    };

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [22];

    users.users.root.openssh.authorizedKeys.keys = deployKeyLines;

    programs.ssh = {
      knownHosts = {
        hyde.publicKey = keys.hostKeys.hyde;
        castor.publicKey = keys.hostKeys.castor;
      };
      extraConfig = ''
        Host hyde castor
          User root
          IdentityFile ~/.ssh/deploy_ed25519
          IdentitiesOnly yes
      '';
    };

    environment.systemPackages = [
      ndeployScript
      nrScript
      nbootScript
      ntestScript
      ntryScript
      nshellScript
    ];
  };
}
