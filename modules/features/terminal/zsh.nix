{ self, inputs, ... }: {
  flake.nixosModules.zsh = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    # NixOS system-level Zsh management
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
        enableCompletion = false;
        autosuggestion.enable = false;
        syntaxHighlighting.enable = false;

        initContent = ''
          # ----------------------------------------------------------------------
          # Asynchronous Performance & Highlighting Optimization
          # ----------------------------------------------------------------------
          export ZSH_AUTOSUGGEST_USE_ASYNC=1
          export ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
          export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#586e75'

          typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

          typeset -A ZSH_HIGHLIGHT_STYLES
          ZSH_HIGHLIGHT_STYLES[command]='fg=#2aa198,bold'
          ZSH_HIGHLIGHT_STYLES[alias]='fg=#2aa198'
          ZSH_HIGHLIGHT_STYLES[builtin]='fg=#268bd2,bold'
          ZSH_HIGHLIGHT_STYLES[function]='fg=#268bd2'
          ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#859900'
          ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#859900'
          ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#859900'
          ZSH_HIGHLIGHT_STYLES[path]='fg=#93a1a1,underline'
          ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#586e75,underline'
          ZSH_HIGHLIGHT_STYLES[globbing]='fg=#b58900'
          ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#268bd2'
          ZSH_HIGHLIGHT_STYLES[command-separator]='fg=#586e75'
          ZSH_HIGHLIGHT_STYLES[redirection]='fg=#586e75'
          ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#dc322f,bold'

          # ----------------------------------------------------------------------
          # Interactive Tools (Single-Hook Execution)
          # ----------------------------------------------------------------------
          eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
          eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

          # ----------------------------------------------------------------------
          # ZLE Cursor Shape Synchronization
          # ----------------------------------------------------------------------
          zle-keymap-select() {
            if [[ $KEYMAP == vicmd ]]; then
              printf '\e[2 q' # Steady block
            else
              printf '\e[6 q' # Steady beam
            fi
          }
          zle -N zle-keymap-select

          zle-line-init() {
            printf '\e[6 q' # Steady beam in insert mode
          }
          zle -N zle-line-init

          # ----------------------------------------------------------------------
          # Native ZLE Auto-Expanding Abbreviations (Zero Aliases)
          # ----------------------------------------------------------------------
          typeset -Ag abbreviations
          abbreviations=(
            # Clipboard & Streams
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

            # Directory Navigation & Zoxide
            [l]="ls"
            [ll]="ls -l"
            [la]="ls -a"
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
            if [[ -n "$match_word" && -n "''${abbreviations[$match_word]}" ]]; then
              LBUFFER="''${LBUFFER%$match_word}''${abbreviations[$match_word]}"
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

          # Unified LLM System Context Engine (Replaces cft and cfb)
          cfb() {
            local target="."
            if [[ $# -ge 1 ]]; then
              case "$1" in
                nix) target="/etc/nixos" ;;
                cfg) target="$HOME/.config" ;;
                *) target="$1" ;;
              esac
            fi

            target=$(realpath "$target" 2>/dev/null || echo "$target")
            if [[ ! -d "$target" ]]; then
              echo "Error: Target directory '$target' does not exist." >&2
              return 1
            fi

            echo "Generating structured LLM context snapshot for: $target..."

            local host_name="$(hostname 2>/dev/null || echo "workstation")"
            local user_name="$(whoami 2>/dev/null || echo "user")"
            local date_str="$(date '+%Y-%m-%d %H:%M:%S')"

            local output="================================================================================
SYSTEM CONTEXT SNAPSHOT
Host: $host_name | User: $user_name | Target: $target | Date: $date_str
================================================================================

--------------------------------------------------------------------------------
DIRECTORY TOPOLOGY (including empty directories)
--------------------------------------------------------------------------------
"

            if [[ "$target" == *".config"* ]]; then
              output+=$(tree "$target" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|BraveSoftware|floorp|google-chrome|chromium' --noreport 2>/dev/null || tree "$target" -a -I '.git|result' --noreport)
            else
              output+=$(tree "$target" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null || tree "$target" --noreport)
            fi

            output+=$'\n\n'
            output+="--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------"
            output+=$'\n'

            local extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e zsh -e sh -e py -e css -e lua -e md)
            local excludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "BraveSoftware" -E "floorp" -E "google-chrome")

            local files=($(fd . "$target" -t f -L -H -S -50k "''${extensions[@]}" "''${excludes[@]}" 2>/dev/null))
            local file_count=''${#files[@]}

            if [[ $file_count -eq 0 ]]; then
              output+=$'\n[No configuration files found matching extension filters.]\n'
            else
              for file in "''${files[@]}"; do
                local rel_path="''${file#$target/}"
                output+=$'\n--- START OF FILE: '"$rel_path"$' ---\n'
                output+="$(cat "$file" 2>/dev/null)"$'\n'
                output+='--- END OF FILE: '"$rel_path"$' ---\n'
              done
            fi

            printf "%s" "$output" | wl-copy
            local byte_size=$(printf "%s" "$output" | wc -c)
            local kb_size=$(( byte_size / 1024 ))
            echo "[Copied context: Tree + $file_count files (''${kb_size} KB) from $target to clipboard]"
          }
        '';
      };
    };
  };
}
