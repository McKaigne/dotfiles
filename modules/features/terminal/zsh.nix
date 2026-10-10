{ self, inputs, ... }: {
  flake.nixosModules.zsh = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };

    users.users.${user}.shell = pkgs.zsh;

    programs.starship = {
      enable = true;
      package = pkgs.starship;
    };

    environment.sessionVariables = {
      STARSHIP_CONFIG = "/etc/starship.toml";
      SHELL = "${pkgs.zsh}/bin/zsh";
      EDITOR = "hx";
      VISUAL = "hx";
    };

    environment.variables = {
      SHELL = "${pkgs.zsh}/bin/zsh";
    };

    environment.etc."starship.toml".source = ./starship.toml;

    environment.systemPackages = with pkgs; [
      zsh
      starship
      zoxide
      fzf
      direnv
      eza
      bat
      fd
      ripgrep
      tree
      jq
      yazi
      btop
      wl-clipboard
    ];

    home-manager.users.${user} = {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;

        initContent = ''
          # ----------------------------------------------------------------------
          # Interactive Tools Integration
          # ----------------------------------------------------------------------
          eval "$(${pkgs.starship}/bin/starship init zsh)"
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

          # ----------------------------------------------------------------------
          # Native ZLE Auto-Expanding Abbreviations (Zero Aliases)
          # ----------------------------------------------------------------------
          typeset -Ag abbreviations
          abbreviations=(
            # Clipboard
            [toclip]="| wl-copy"
            [fromclip]="wl-paste"
            [silent]="&> /dev/null"
            [noerr]="2> /dev/null"

            # Formats
            [tojson]="| jq ."
            [fromjson]="| jq ."

            # System Rebuilds
            [rebuild]="sudo nixos-rebuild switch --flake /etc/nixos"
            [rebuildc]="sudo nixos-rebuild switch --flake /etc/nixos#castor"
            [rebuildh]="sudo nixos-rebuild switch --flake /etc/nixos#hyde"
            [nr]="sudo nixos-rebuild switch --flake /etc/nixos"
            [nboot]="sudo nixos-rebuild boot --flake /etc/nixos"
            [ntest]="sudo nixos-rebuild test --flake /etc/nixos"
            [ncd]="cd /etc/nixos"
            [nupdate]="nix flake update --flake /etc/nixos"
            [nclean]="nix-collect-garbage -d"
            [ntry]="nix run nixpkgs#"
            [nshell]="nix shell nixpkgs#"
            [ntrace]="--show-trace"

            # Git
            [ga]="git add -A"
            [gstage]="git add -A"
            [gpatch]="git add -p"
            [gundo]="git reset --soft HEAD~1"
            [gunstage]="git restore --staged ."
            [gwipe]="git reset --hard HEAD"
            [gamend]="git commit --amend --no-edit"
            [gst]="git status"
            [gc]="git commit -m"
            [gdiff]="git diff"
            [gdiffs]="git diff --staged"
            [gp]="git push"
            [gpushf]="git push --force-with-lease"
            [gpl]="git pull"
            [glg]="git log --oneline --graph -n 20"
            [gbranch]="git switch"
            [gnew]="git switch -c"

            # Noctalia IPC
            [nlaunch]="noctalia msg panel-toggle launcher"
            [ncontrol]="noctalia msg panel-toggle control-center"
            [nsession]="noctalia msg panel-toggle session"
            [nclip]="noctalia msg panel-toggle clipboard"
            [nsettings]="noctalia msg settings-toggle"
            [nbar]="noctalia msg bar-toggle"
            [nlock]="noctalia msg session lock"
            [nclosemsg]="noctalia msg notification-clear-active"

            # Niri IPC
            [nreload]="niri msg action load-config-file"
            [nclose]="niri msg action close-window"
            [nquit]="niri msg action quit"
            [nfocus]="niri msg action focus-window --id"
            [nwins]="niri msg -j windows"
            [nwork]="niri msg -j workspaces"
            [nmon]="niri msg -j outputs"

            # Tmux
            [t]="tmux"
            [ta]="tmux attach -t"
            [tls]="tmux ls"
            [tkill]="tmux kill-session -t"
            [tkilla]="tmux kill-server"

            # Zoxide
            [zq]="zoxide query"
            [zql]="zoxide query -l"
            [za]="zoxide add"
            [zr]="zoxide remove"

            # Editors & Utilities
            [v]="hx"
            [vi]="hx"
            [vim]="hx"
            [bottom]="btop"
            [btm]="btop"
            [y]="yazi"
            [g]="git"
            [lg]="lazygit"
            [music]="cliamp"
            [amp]="cliamp"

            # Flake Shortcuts
            [hxf]="hx /etc/nixos/flake.nix"
            [hxh]="hx /etc/nixos/modules/hosts/hyde/default.nix"
            [hxc]="hx /etc/nixos/modules/shared/core.nix"
            [hxz]="hx /etc/nixos/modules/features/terminal/zsh.nix"
            [hxi]="hx /etc/nixos/modules/features/desktop/config.kdl"
            [hxt]="hx /etc/nixos/modules/features/terminal/tmux.nix"
          )

          expand-abbreviation() {
            local match_word="''${LBUFFER##*[$' \t;|']}"
            if [[ -n "$match_word" && -n "$abbreviations[$match_word]" ]]; then
              LBUFFER="''${LBUFFER%$match_word}$abbreviations[$match_word]"
            fi
          }

          expand-abbreviation-space() {
            expand-abbreviation
            zle self-insert
          }

          expand-abbreviation-enter() {
            expand-abbreviation
            zle accept-line
          }

          zle -N expand-abbreviation-space
          zle -N expand-abbreviation-enter
          bindkey " " expand-abbreviation-space
          bindkey "^M" expand-abbreviation-enter
          bindkey -M isearch " " self-insert

          # ----------------------------------------------------------------------
          # Interactive Functions
          # ----------------------------------------------------------------------
          fkill() {
            local selected=$(ps -eo pid,user,comm,%cpu,%mem | fzf --header="Select process to kill (ESC to cancel)")
            if [[ -n "$selected" ]]; then
              local target_pid=$(echo "$selected" | awk '{print $1}')
              kill -9 "$target_pid"
              echo "Killed process $target_pid"
            fi
          }

          cft() {
            local target="."
            [[ $# -ge 1 ]] && target="$1"
            local extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e zsh -e py -e css -e lua)
            local excludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log")
            local files=($(fd . "$(realpath "$target")" -t f -L -H -S -50k "''${extensions[@]}" "''${excludes[@]}"))
            if [[ ''${#files[@]} -eq 0 ]]; then
              echo "No configuration files found in $target"
              return
            fi
            local tree_out=$(printf "%s\n" "''${files[@]}" | tree -a -F --fromfile)
            echo "$tree_out" | wl-copy
            echo "$tree_out"
            echo -e "\n[Copied tree of ''${#files[@]} core config files to clipboard]"
          }

          cfb() {
            local target="."
            [[ $# -ge 1 ]] && target="$1"
            local extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e zsh -e py -e css -e lua)
            local excludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log")
            local files=($(fd . "$(realpath "$target")" -t f -L -H -S -50k "''${extensions[@]}" "''${excludes[@]}"))
            if [[ ''${#files[@]} -eq 0 ]]; then
              echo "No configuration files found in $target"
              return
            fi
            local content=""
            for f in "''${files[@]}"; do
              content+="$(bat --style=header,grid --paging=never "$f")"$'\n'
            done
            printf "%s" "$content" | wl-copy
            echo "[Copied full content of ''${#files[@]} config files to clipboard]"
          }
        '';
      };
    };
  };
}
