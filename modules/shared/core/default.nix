_:
let
  cfb =
    { pkgs }:
    pkgs.writeShellScriptBin "cfb" ''
      set -euo pipefail

      targetPath="."
      if [ $# -ge 1 ]; then
        case "$1" in
          nix) targetPath="/etc/nixos" ;;
          cfg) targetPath="$HOME/.config" ;;
          *) targetPath="$1" ;;
        esac
      fi

      targetPath="$(realpath "$targetPath" 2>/dev/null || echo "$targetPath")"
      if [ ! -d "$targetPath" ]; then
        echo "Error: Target directory '$targetPath' does not exist." >&2
        exit 1
      fi

      echo "Generating structured LLM context snapshot for: $targetPath..." >&2

      hostName="$(hostname 2>/dev/null || echo workstation)"
      userName="$(whoami 2>/dev/null || echo user)"
      dateString="$(date '+%Y-%m-%d %H:%M:%S')"

      tmpfile="$(mktemp)"
      trap 'rm -f "$tmpfile"' EXIT

      cat << SNAP_HEADER > "$tmpfile"
================================================================================
SYSTEM CONTEXT SNAPSHOT
Host: $hostName | User: $userName | Target: $targetPath | Date: $dateString
================================================================================

--------------------------------------------------------------------------------
DIRECTORY TOPOLOGY (including empty directories)
--------------------------------------------------------------------------------
SNAP_HEADER

      if [[ "$targetPath" == *".config"* ]]; then
        treeIgnores='.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|*asar*|*BraveSoftware*|*brave*|*chromium*|*floorp*|*librewolf*|*mozilla*|*google-chrome*|*obsidian*|*zennotes*|*Ferdium*|*OpenRGB*|*credential*|*token*|*secret*|*.key|*LearnHarness*|*gh*'
        ${pkgs.tree}/bin/tree "$targetPath" -a -I "$treeIgnores" --noreport 2>/dev/null >> "$tmpfile" || ${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|result' --noreport >> "$tmpfile"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*asar" -E "*BraveSoftware*" -E "*brave*" -E "*chromium*" -E "*floorp*" -E "*librewolf*" -E "*mozilla*" -E "*google-chrome*" -E "*obsidian*" -E "*zennotes*" -E "*Ferdium*" -E "*OpenRGB*" -E "*credential*" -E "*token*" -E "*secret*" -E "*.key" -E "*LearnHarness*" -E "*gh*")
      else
        ${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null >> "$tmpfile" || ${pkgs.tree}/bin/tree "$targetPath" --noreport >> "$tmpfile"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*credential*" -E "*token*" -E "*secret*" -E "*.key" -E "*LearnHarness*" -E "*gh*")
      fi

      cat << 'CONTENTS_HEADER' >> "$tmpfile"

--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------
CONTENTS_HEADER

      extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e fish -e zsh -e sh -e py -e css -e lua -e md)

      count=0
      while IFS= read -r -d $'\0' file; do
        relPath="''${file#$targetPath/}"
        printf '\n--- START OF FILE: %s ---\n' "$relPath" >> "$tmpfile"
        cat "$file" >> "$tmpfile" 2>/dev/null || true
        printf '\n--- END OF FILE: %s ---\n' "$relPath" >> "$tmpfile"
        count=$((count + 1))
      done < <(${pkgs.fd}/bin/fd . "$targetPath" -t f -L -H -S -250k "''${extensions[@]}" "''${fdExcludes[@]}" -0 2>/dev/null)

      if [ "$count" -eq 0 ]; then
        printf '\n[No configuration files found matching extension filters.]\n' >> "$tmpfile"
      fi

      if command -v ${pkgs.wl-clipboard}/bin/wl-copy >/dev/null 2>&1 && [ -n "''${WAYLAND_DISPLAY:-}" ]; then
        ${pkgs.wl-clipboard}/bin/wl-copy < "$tmpfile"
        byteSize=$(wc -c < "$tmpfile")
        kilobyteSize=$(( byteSize / 1024 ))
        echo "[Copied context: Tree + $count files ($kilobyteSize KB) from $targetPath to clipboard]" >&2
      else
        cat "$tmpfile"
        echo "[Wayland session not detected: output dumped to stdout]" >&2
      fi
    '';
in
{
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      cfbPkg = cfb { inherit pkgs; };

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

        if [ "$target" = "$cur" ]; then
          echo "==> Deploying locally to $cur ($verb)..."
          git -C /etc/nixos add -A && nh os "$verb"
          exit 0
        fi

        echo "==> Preflight: Checking reachability of root@$target via Tailscale..."
        if ! ssh -o BatchMode=yes -o ConnectTimeout=5 "root@$target" true 2>/dev/null; then
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

      televisionWrapped = pkgs.symlinkJoin {
        name = "television-alias";
        paths = [ pkgs.television ];
        postBuild = ''
          ln -sf $out/bin/tv $out/bin/television
        '';
      };
    in
    {

      options.workstation.shellAbbrs = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Unified single-source abbreviation mappings across Fish and Zsh (Space-expanded only)";
        default = {
          f = "tv";
          television = "tv";

          ncd = "cd /etc/nixos";
          nupdate = "nix flake update --flake /etc/nixos";
          nclean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

          ga = "git add -A";
          gstage = "git add -A";
          gpatch = "git add -p";
          gundo = "git reset --soft HEAD~1";
          gunstage = "git restore --staged .";
          gwipe = "git reset --hard HEAD";
          gamend = "git commit --amend --no-edit";
          gst = "git status";
          gc = "git commit -m";
          gdiff = "git diff";
          gdiffs = "git diff --staged";
          gp = "git push";
          gpushf = "git push --force-with-lease";
          gpl = "git pull";
          glg = "git log --oneline --graph -n 20";
          gbranch = "git switch";
          gnew = "git switch -c";

          nlaunch = "noctalia msg panel-toggle launcher";
          ncontrol = "noctalia msg panel-toggle control-center";
          nsession = "noctalia msg panel-toggle session";
          nclip = "noctalia msg panel-toggle clipboard";
          nsettings = "noctalia msg settings-toggle";
          nbar = "noctalia msg bar-toggle";
          nlock = "noctalia msg session lock";
          nclosemsg = "noctalia msg notification-clear-active";

          nreload = "niri msg action load-config-file";
          nclose = "niri msg action close-window";
          nquit = "niri msg action quit";
          nfocus = "niri msg action focus-window --id";
          nwins = "niri msg -j windows";
          nwork = "niri msg -j workspaces";
          nmon = "niri msg -j outputs";

          zj = "zellij";
          zja = "zellij attach";
          zjls = "zellij list-sessions";
          zjkill = "zellij kill-session";
          zjkilla = "zellij kill-all-sessions";

          zq = "zoxide query";
          zql = "zoxide query -l";
          za = "zoxide add";
          zr = "zoxide remove";

          h = "hx";
          v = "hx";
          vi = "hx";
          vim = "hx";
          nv = "hx";
          bottom = "btop";
          btm = "btop";
          n = "nnn";
          g = "git";
          lg = "lazygit";

          nvf = "nvim /etc/nixos/flake.nix";
          nvh = "nvim /etc/nixos/modules/hosts/hyde/default.nix";
          nvc = "nvim /etc/nixos/modules/shared/core/default.nix";
          nvfish = "nvim /etc/nixos/modules/features/terminal/fish/default.nix";
          nvi = "nvim /etc/nixos/modules/features/desktop/niri/niri.kdl";
          nvt = "nvim /etc/nixos/modules/features/terminal/tmux/default.nix";
        };
      };

      config = {
        boot.loader.systemd-boot.configurationLimit = 10;
        services.fstrim.enable = true;
        programs.nh = {
          enable = true;
          flake = "/etc/nixos";
          clean = {
            enable = true;
            dates = "weekly";
            extraArgs = "--keep-since 14d";
          };
        };

        nixpkgs.config.allowUnfree = true;
        i18n.defaultLocale = "en_US.UTF-8";

        nix.settings = {
          experimental-features = [
            "nix-command"
            "flakes"
          ];
          warn-dirty = false;
          auto-optimise-store = true;
          max-jobs = "auto";
          cores = 0;
          substituters = [
            "https://cache.nixos.org"
            "https://devenv.cachix.org"
            "https://noctalia.cachix.org"
            "https://nix-community.cachix.org"
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          ];
        };

        systemd.tmpfiles.rules = [
          "d /etc/nixos 0775 ${user} wheel -"
          "z /etc/nixos 0775 ${user} wheel -"
        ];

        boot.kernel.sysctl = {
          "fs.inotify.max_user_watches" = 1048576;
          "fs.inotify.max_user_instances" = 1024;
        };

        security.sudo.extraConfig = ''
          Defaults passwd_timeout=0
          Defaults timestamp_timeout=30
        '';

        environment.localBinInPath = true;


        hardware.keyboard.qmk.enable = true;

        services.udev.extraRules = ''
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", ATTRS{idProduct}=="0051", MODE="0660", GROUP="users", TAG+="uaccess"
          KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", MODE="0660", GROUP="users", TAG+="uaccess"
        '';

        environment.sessionVariables = {
          EDITOR = "hx";
          VISUAL = "hx";
          BAT_THEME = "Catppuccin Mocha";
          GLOW_STYLE = "catppuccin-mocha";
          STARSHIP_CONFIG = "/etc/starship.toml";

          FZF_DEFAULT_OPTS = "--color=bg+:${config.palette.surface0},bg:-1,spinner:${config.palette.rosewater},hl:${config.palette.red} --color=fg:${config.palette.text},header:${config.palette.red},info:${config.palette.mauve},pointer:${config.palette.rosewater} --color=marker:${config.palette.lavender},fg+:${config.palette.text},prompt:${config.palette.mauve},hl+:${config.palette.red} --height=50% --layout=reverse --border=none --info=inline --prompt='➜ ' --pointer='▶ ' --marker='✓ '";
          FZF_DEFAULT_COMMAND = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
          FZF_CTRL_T_COMMAND = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
          FZF_CTRL_T_OPTS = "--preview '${pkgs.bat}/bin/bat -n --color=always --line-range :500 {}' --preview-window=right:60%:wrap";
          FZF_ALT_C_COMMAND = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
          FZF_ALT_C_OPTS = "--preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always {} | head -200' --preview-window=right:60%:wrap";

          NNN_COLORS = "2134";
          NNN_FCOLORS = "c1e2272e006033f7c6d6abc4";
        };

        home-manager.users.${user} = {
          programs.zoxide = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };

          programs.fzf = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            defaultCommand = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
            fileWidget.command = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
            changeDirWidget.command = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
            historyWidget.command = "";
          };


          programs.atuin = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            settings = {
              style = "compact";
              inline_height = 20;
              show_preview = true;
              update_check = false;
            };
          };
        };

        environment.systemPackages = with pkgs; [
          ndeployScript
          nrScript
          nbootScript
          ntestScript
          ntryScript
          nshellScript
          televisionWrapped
          psmisc
          delta
          lazygit
          gh
          tree
          btop
          bat
          eza
          dysk
          silicon
          tealdeer
          dust
          gdu
          procs
          ripgrep
          fd
          findutils
          jq
          jnv
          sd
          xh
          curl
          nnn
          gawk
          vivid
          cfbPkg
          aria2
          p7zip
          unrar
          rsync
          devenv
          wl-clipboard
          nodejs_22
          python3
        ];
      };
    };
}
