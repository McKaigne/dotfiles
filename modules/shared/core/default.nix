{ self, inputs, ... }:
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
        treeIgnores='.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|*asar*|*BraveSoftware*|*brave*|*chromium*|*floorp*|*librewolf*|*mozilla*|*google-chrome*|*obsidian*|*zennotes*|*Ferdium*|*OpenRGB*'
        ${pkgs.tree}/bin/tree "$targetPath" -a -I "$treeIgnores" --noreport 2>/dev/null >> "$tmpfile" || ${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|result' --noreport >> "$tmpfile"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*asar" -E "*BraveSoftware*" -E "*brave*" -E "*chromium*" -E "*floorp*" -E "*librewolf*" -E "*mozilla*" -E "*google-chrome*" -E "*obsidian*" -E "*zennotes*" -E "*Ferdium*" -E "*OpenRGB*")
      else
        ${pkgs.tree}/bin/tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null >> "$tmpfile" || ${pkgs.tree}/bin/tree "$targetPath" --noreport >> "$tmpfile"
        fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*")
      fi

      cat << 'CONTENTS_HEADER' >> "$tmpfile"

--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------
CONTENTS_HEADER

      extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e fish -e zsh -e sh -e py -e css -e lua -e md -e nu -e xsh)

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

      rebuildScript = pkgs.writeShellScriptBin "rebuild" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos "$@"
      '';
      rebuildhScript = pkgs.writeShellScriptBin "rebuildh" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#hyde "$@"
      '';
      rebuildcScript = pkgs.writeShellScriptBin "rebuildc" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#castor "$@"
      '';
      nrScript = pkgs.writeShellScriptBin "nr" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos "$@"
      '';
      nbootScript = pkgs.writeShellScriptBin "nboot" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild boot --flake /etc/nixos "$@"
      '';
      ntestScript = pkgs.writeShellScriptBin "ntest" ''
        set -euo pipefail
        git -C /etc/nixos add -A && sudo nixos-rebuild test --flake /etc/nixos "$@"
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

      # Symlink television -> tv so both invocations work
      televisionWrapped = pkgs.symlinkJoin {
        name = "television-alias";
        paths = [ pkgs.television ];
        postBuild = ''
          ln -sf $out/bin/tv $out/bin/television
        '';
      };
    in
    {
      options.workstation.shellAliases = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Single source of truth for aliases across bash, zsh, fish, nushell, and xonsh";
        default = {
          grep = "rg";
          find = "fd";
          sed = "sd";
          du = "dust";
          cat = "bat";
          ls = "eza";
          exa = "eza";

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

          t = "tmux";
          ta = "tmux attach -t";
          tls = "tmux ls";
          tkill = "tmux kill-session -t";
          tkilla = "tmux kill-server";

          l = "eza";
          ll = "eza -l";
          la = "eza -la";
          zq = "zoxide query";
          zql = "zoxide query -l";
          za = "zoxide add";
          zr = "zoxide remove";

          v = "hx";
          vi = "hx";
          vim = "hx";
          bottom = "btop";
          btm = "btop";
          n = "nnn";
          g = "git";
          lg = "lazygit";
          lh = "learnharness";

          hxf = "hx /etc/nixos/flake.nix";
          hxh = "hx /etc/nixos/modules/hosts/hyde/default.nix";
          hxc = "hx /etc/nixos/modules/shared/core/default.nix";
          hxfish = "hx /etc/nixos/modules/features/terminal/fish/default.nix";
          hxi = "hx /etc/nixos/modules/features/desktop/niri/niri.kdl";
          hxt = "hx /etc/nixos/modules/features/terminal/tmux/default.nix";
        };
      };

      options.workstation.shellAbbrs = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Unified abbreviation mapping for Fish and Zsh-abbr";
        default = config.workstation.shellAliases;
      };

      config = {
        boot.loader.systemd-boot.configurationLimit = 10;
        services.fstrim.enable = true;
        nix.gc = {
          automatic = true;
          dates = "weekly";
          options = "--delete-older-than 14d";
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
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
            "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
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

        programs.nix-ld = {
          enable = true;
          libraries = with pkgs; [
            stdenv.cc.cc.lib
            zlib
            openssl
            curl
            glibc
          ];
        };

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

          FZF_DEFAULT_OPTS = "--color=bg+:#313244,bg:-1,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --height=50% --layout=reverse --border=none --info=inline --prompt='➜ ' --pointer='▶ ' --marker='✓ '";
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
            enableNushellIntegration = true;
          };

          programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            enableNushellIntegration = true;
          };

          programs.starship = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            enableNushellIntegration = true;
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

          programs.mise = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
          };

          programs.atuin = {
            enable = true;
            enableBashIntegration = true;
            enableZshIntegration = true;
            enableFishIntegration = true;
            enableNushellIntegration = true;
            settings = {
              style = "compact";
              inline_height = 20;
              show_preview = true;
              update_check = false;
            };
          };
        };

        environment.systemPackages = with pkgs; [
          rebuildScript
          rebuildhScript
          rebuildcScript
          nrScript
          nbootScript
          ntestScript
          ntryScript
          nshellScript
          televisionWrapped
          git
          delta
          lazygit
          gh
          tree
          btop
          bat
          eza
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
          wtype
          gawk
          fzf
          mise
          atuin
          vivid
          cfbPkg
          aria2
          p7zip
          unrar
          rsync
          devenv
          nvd
          nix-output-monitor
          wl-clipboard
          nodejs_22
          uv
          python3
        ];
      };
    };
}
