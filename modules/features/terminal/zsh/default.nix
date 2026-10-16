{ self, inputs, ... }: {
  flake.nixosModules.zsh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };

      users.users.${user}.shell = pkgs.zsh;

      environment.sessionVariables = {
        SHELL = "${pkgs.zsh}/bin/zsh";
      };

      environment.systemPackages = with pkgs; [
        zsh
        zsh-abbr
        zoxide
        fzf
      ];

      home-manager.users.${user} = {
        programs.zsh = {
          enable = true;
          enableCompletion = false;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

          history = {
            size = 50000;
            save = 50000;
            path = "$HOME/.zsh_history";
            share = true;
            ignoreDups = true;
            ignoreAllDups = true;
            ignoreSpace = true;
          };

          zsh-abbr = {
            enable = true;
            abbreviations = {
              rebuild = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
              rebuildc = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#castor";
              rebuildh = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#hyde";
              nr = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
              nboot = "git -C /etc/nixos add -A && sudo nixos-rebuild boot --flake /etc/nixos";
              ntest = "git -C /etc/nixos add -A && sudo nixos-rebuild test --flake /etc/nixos";
              ncd = "cd /etc/nixos";
              nupdate = "nix flake update --flake /etc/nixos";
              nclean = "nix-collect-garbage -d";
              ntry = "nix run nixpkgs#";
              nshell = "nix shell nixpkgs#";
              ntrace = "--show-trace";

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

              l = "ls";
              ll = "ls -l";
              la = "ls -a";
              zq = "zoxide query";
              zql = "zoxide query -l";
              za = "zoxide add";
              zr = "zoxide remove";

              v = "hx";
              vi = "hx";
              vim = "hx";
              bottom = "btop";
              btm = "btop";
              y = "yazi";
              g = "git";
              lg = "lazygit";
              fetch = "fetch";

              hxf = "hx /etc/nixos/flake.nix";
              hxh = "hx /etc/nixos/modules/hosts/hyde/default.nix";
              hxc = "hx /etc/nixos/modules/shared/core/default.nix";
              hxz = "hx /etc/nixos/modules/features/terminal/zsh/default.nix";
              hxi = "hx /etc/nixos/modules/features/desktop/niri/niri.kdl";
              hxt = "hx /etc/nixos/modules/features/terminal/tmux/default.nix";
            };
            globalAbbreviations = {
              toclip = "| wl-copy";
              fromclip = "wl-paste";
              silent = "&> /dev/null";
              noerr = "2> /dev/null";
              tojson = "| jq .";
              fromjson = "| jq .";
            };
          };

          initContent = ''
            export ZSH_AUTOSUGGEST_USE_ASYNC=1
            export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
            export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

            typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

            typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[command]='fg=#cba6f7,bold'
            ZSH_HIGHLIGHT_STYLES[alias]='fg=#b4befe'
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa,bold'
            ZSH_HIGHLIGHT_STYLES[function]='fg=#89b4fa'
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
            ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#6c7086,underline'
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
            ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#89b4fa'
            ZSH_HIGHLIGHT_STYLES[command-separator]='fg=#6c7086'
            ZSH_HIGHLIGHT_STYLES[redirection]='fg=#6c7086'
            ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'

            export FZF_DEFAULT_OPTS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

            eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

            bindkey -e

            fkill() {
              local selectedProc=$(ps -eo pid,user,comm,%cpu,%mem | fzf --header="Select process to kill (ESC to cancel)")
              if [[ -n "$selectedProc" ]]; then
                local targetPid=$(echo "$selectedProc" | awk '{print $1}')
                kill -9 "$targetPid" && echo "Killed process $targetPid"
              fi
            }

            nsync() {
              local targetHost
              targetHost=$(hostname 2>/dev/null || echo "hyde")
              local targetFile="/etc/nixos/modules/features/desktop/noctalia/noctalia.toml"
              local stateFile="$HOME/.local/state/noctalia/settings.toml"

              echo "==> [1/5] Exporting Noctalia merged configuration via IPC..."
              noctalia config export > "$targetFile" || {
                echo "Error: Failed to export config via noctalia IPC." >&2
                return 1
              }

              echo "==> [2/5] Normalizing wallpaper paths and enforcing template suppression..."
              sed -i -E 's|directory = "[^"]*wallpapers"|directory = "/etc/wallpapers"|g' "$targetFile"
              sed -i -E 's|path = "[^"]*/wallpapers/([^"]+)"|path = "/etc/wallpapers/\1"|g' "$targetFile"

              if grep -q "\[theme\.templates\]" "$targetFile"; then
                sed -i -E 's/enable_builtin_templates = true/enable_builtin_templates = false/g' "$targetFile"
                sed -i -E 's/enable_community_templates = true/enable_community_templates = false/g' "$targetFile"
              else
                printf '\n[theme.templates]\nenable_builtin_templates = false\nenable_community_templates = false\n' >> "$targetFile"
              fi

              echo "==> [3/5] Staging changes in git..."
              git -C /etc/nixos add -A || {
                echo "Error: Git staging failed." >&2
                return 1
              }

              echo "==> [4/5] Rebuilding NixOS generation for host: ''${targetHost}..."
              if sudo nixos-rebuild switch --flake "/etc/nixos#''${targetHost}"; then
                echo "==> [5/5] Purging mutable runtime state override..."
                rm -f "$stateFile"
                echo "==> Noctalia declarative state synchronized and baked into system generation."
              else
                echo "Error: nixos-rebuild failed. Runtime state preserved for recovery." >&2
                return 1
              fi
            }

            cfb() {
              local targetPath="."
              if [[ $# -ge 1 ]]; then
                case "$1" in
                  nix) targetPath="/etc/nixos" ;;
                  cfg) targetPath="$HOME/.config" ;;
                  *) targetPath="$1" ;;
                esac
              fi

              targetPath=$(realpath "$targetPath" 2>/dev/null || echo "$targetPath")
              if [[ ! -d "$targetPath" ]]; then
                echo "Error: Target directory '$targetPath' does not exist." >&2
                return 1
              fi

              echo "Generating structured LLM context snapshot for: $targetPath..."

              local hostName="$(hostname 2>/dev/null || echo "workstation")"
              local userName="$(whoami 2>/dev/null || echo "user")"
              local dateString="$(date '+%Y-%m-%d %H:%M:%S')"

              local outputStr="================================================================================
SYSTEM CONTEXT SNAPSHOT
Host: $hostName | User: $userName | Target: $targetPath | Date: $dateString
================================================================================

--------------------------------------------------------------------------------
DIRECTORY TOPOLOGY (including empty directories)
--------------------------------------------------------------------------------
"

              local extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e zsh -e sh -e py -e css -e lua -e md)
              local -a fdExcludes

              if [[ "$targetPath" == *".config"* ]]; then
                local treeIgnores='.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|*asar*|*BraveSoftware*|*brave*|*chromium*|*floorp*|*librewolf*|*mozilla*|*google-chrome*|*obsidian*'
                outputStr+=$(tree "$targetPath" -a -I "$treeIgnores" --noreport 2>/dev/null || tree "$targetPath" -a -I '.git|result' --noreport)
                fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*asar" -E "*BraveSoftware*" -E "*brave*" -E "*chromium*" -E "*floorp*" -E "*librewolf*" -E "*mozilla*" -E "*google-chrome*" -E "*obsidian*")
              else
                outputStr+=$(tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null || tree "$targetPath" --noreport)
                fdExcludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*")
              fi

              outputStr+=$'\n\n'
              outputStr+="--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------"
              outputStr+=$'\n'

              local -a files
              files=("''${(@f)$(fd . "$targetPath" -t f -L -H -S -250k "''${extensions[@]}" "''${fdExcludes[@]}" 2>/dev/null)}")
              files=("''${files[@]:#}")
              local fileCount=''${#files[@]}

              if [[ $fileCount -eq 0 ]]; then
                outputStr+=$'\n[No configuration files found matching extension filters.]\n'
              else
                for file in "''${files[@]}"; do
                  local relPath="''${file#$targetPath/}"
                  outputStr+=$'\n--- START OF FILE: '"$relPath"$' ---\n'
                  outputStr+="$(cat "$file" 2>/dev/null)"$'\n'
                  outputStr+='--- END OF FILE: '"$relPath"$' ---\n'
                done
              fi

              printf "%s" "$outputStr" | wl-copy
              local byteSize=$(printf "%s" "$outputStr" | wc -c)
              local kilobyteSize=$(( byteSize / 1024 ))
              echo "[Copied context: Tree + $fileCount files (''${kilobyteSize} KB) from $targetPath to clipboard]"
            }
          '';
        };
      };
    };
}
