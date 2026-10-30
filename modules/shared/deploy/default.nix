_: {
  flake.nixosModules.deploy =
    { config, lib, ... }:
    let
      keys = import ./_keys.nix;
      tailscaleCidr = "100.64.0.0/10,fd7a:115c:a1e0::/48";
      deployKeyLines = lib.mapAttrsToList (
        _name: key: ''from="${tailscaleCidr}" ${key}''
      ) keys.deployKeys;
    in
    {
      assertions = [
        {
          assertion = !lib.hasInfix "AAAA..." (builtins.toJSON keys);
          message = "Deploy keys in _keys.nix must contain real keys, not placeholders.";
        }
        {
          assertion = !config.services.openssh.openFirewall;
          message = "services.openssh.openFirewall must be false; sshd is exposed only on tailscale0.";
        }
        {
          assertion = config.services.openssh.settings.PasswordAuthentication == false;
          message = "sshd PasswordAuthentication must be false.";
        }
        {
          assertion = lib.all (k: lib.hasPrefix "from=" k) config.users.users.root.openssh.authorizedKeys.keys;
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
          AllowUsers = [ "root" ];
          X11Forwarding = false;
        };
      };

      networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 22 ];

      users.users.root.openssh.authorizedKeys.keys = deployKeyLines;

      programs.ssh = {
        knownHosts = {
          hyde = {
            publicKey = keys.hostKeys.hyde;
          };
          castor = {
            publicKey = keys.hostKeys.castor;
          };
        };
        extraConfig = ''
          Host hyde castor
            User root
            IdentityFile ~/.ssh/deploy_ed25519
            IdentitiesOnly yes
        '';
      };
    };
}
