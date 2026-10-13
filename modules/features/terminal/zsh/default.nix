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
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
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
        wl-clipboard
        tree
        fd
      ];

      home-manager.users.${user} = {
        programs.zsh = {
          enable = true;
          enableCompletion = false;
          autosuggestion.enable = false;
          syntaxHighlighting.enable = false;

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
              rebuild = "sudo nixos-rebuild switch --flake /etc/nixos";
              rebuildc = "sudo nixos-rebuild switch --flake /etc/nixos#castor";
              rebuildh = "sudo nixos-rebuild switch --flake /etc/nixos#hyde";
              nr = "sudo nixos-rebuild switch --flake /etc/nixos";
              nboot = "sudo nixos-rebuild boot --flake /etc/nixos";
              ntest = "sudo nixos-rebuild test --flake /etc/nixos";
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
            ZSH_HIGHLIGHT_STYLES[command]='fg=cyan,bold'
            ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=blue,bold'
            ZSH_HIGHLIGHT_STYLES[function]='fg=blue'
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=green'
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=green'
            ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=green'
            ZSH_HIGHLIGHT_STYLES[path]='fg=7,underline'
            ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=8,underline'
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=yellow'
            ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=blue'
            ZSH_HIGHLIGHT_STYLES[command-separator]='fg=8'
            ZSH_HIGHLIGHT_STYLES[redirection]='fg=8'
            ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'

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

              if [[ "$targetPath" == *".config"* ]]; then
                outputStr+=$(tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|BraveSoftware|floorp|google-chrome|chromium' --noreport 2>/dev/null || tree "$targetPath" -a -I '.git|result' --noreport)
              else
                outputStr+=$(tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null || tree "$targetPath" --noreport)
              fi

              outputStr+=$'\n\n'
              outputStr+="--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------"
              outputStr+=$'\n'

              local extensions=(-e nix -e kdl -e toml -e conf -e ini -e el -e json -e zsh -e sh -e py -e css -e lua -e md)
              local excludes=(-E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "BraveSoftware" -E "floorp" -E "google-chrome")

              local -a files
              files=("''${(@f)$(fd . "$targetPath" -t f -L -H -S -50k "''${extensions[@]}" "''${excludes[@]}" 2>/dev/null)}")
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
