{ self, inputs, ... }: {
  flake.nixosModules.fish =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      programs.fish.enable = true;
      users.users.${user}.shell = pkgs.fish;

      environment.sessionVariables = {
        SHELL = "${pkgs.fish}/bin/fish";
      };

      environment.systemPackages = with pkgs; [
        fish
        fzf
        zoxide
        direnv
        gawk
        tree
        fd
      ];

      home-manager.users.${user} = {
        programs.fish = {
          enable = true;

          shellInit = ''
            set -g fish_greeting ""

            # Ensure local and cargo binaries are always in PATH
            fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin

            # Catppuccin Mocha Syntax Highlighting Palette
            set -g fish_color_normal ${p.hex.text}
            set -g fish_color_command ${p.hex.mauve} --bold
            set -g fish_color_keyword ${p.hex.red}
            set -g fish_color_quote ${p.hex.green}
            set -g fish_color_redirection ${p.hex.surface2}
            set -g fish_color_end ${p.hex.peach}
            set -g fish_color_error ${p.hex.red} --bold
            set -g fish_color_param ${p.hex.text}
            set -g fish_color_comment ${p.hex.surface2}
            set -g fish_color_selection --background=${p.hex.surface0}
            set -g fish_color_search_match --background=${p.hex.surface1}
            set -g fish_color_operator ${p.hex.mauve}
            set -g fish_color_escape ${p.hex.pink}
            set -g fish_color_autosuggestion ${p.hex.surface2}

            # FZF Catppuccin Mocha integration
            set -gx FZF_DEFAULT_OPTS "--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

            # Shell Hooks
            ${pkgs.zoxide}/bin/zoxide init fish | source
            ${pkgs.direnv}/bin/direnv hook fish | source
          '';

          shellAbbrs = {
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
            hxfish = "hx /etc/nixos/modules/features/terminal/fish/default.nix";
            hxi = "hx /etc/nixos/modules/features/desktop/niri/niri.kdl";
            hxt = "hx /etc/nixos/modules/features/terminal/tmux/default.nix";
          };

          functions = {
            writefile = {
              description = "Write raw stdin to file until delimiter (default: EOF) without parsing errors";
              argumentNames = [ "file" "delim" ];
              body = ''
                if test -z "$file"
                    echo "Usage: writefile <target_file> [delimiter=EOF]" >&2
                    return 1
                end
                if test -z "$delim"
                    set delim "EOF"
                end
                ${pkgs.gawk}/bin/awk -v d="$delim" '$0 == d { exit } { print }' > "$file"
              '';
            };

            appendfile = {
              description = "Append raw stdin to file until delimiter (default: EOF) without parsing errors";
              argumentNames = [ "file" "delim" ];
              body = ''
                if test -z "$file"
                    echo "Usage: appendfile <target_file> [delimiter=EOF]" >&2
                    return 1
                end
                if test -z "$delim"
                    set delim "EOF"
                end
                ${pkgs.gawk}/bin/awk -v d="$delim" '$0 == d { exit } { print }' >> "$file"
              '';
            };

            fkill = {
              description = "Interactively select and kill a process";
              body = ''
                set -l selected (ps -eo pid,user,comm,%cpu,%mem | ${pkgs.fzf}/bin/fzf --header="Select process to kill (ESC to cancel)")
                if test -n "$selected"
                    set -l targetPid (echo "$selected" | ${pkgs.gawk}/bin/awk '{print $1}')
                    kill -9 "$targetPid"; and echo "Killed process $targetPid"
                end
              '';
            };

            nsync = {
              description = "Synchronize Noctalia runtime GUI state to declarative base";
              body = ''
                set -l targetHost (hostname 2>/dev/null; or echo "hyde")
                set -l targetFile "/etc/nixos/modules/features/desktop/noctalia/noctalia.toml"
                set -l stateFile "$HOME/.local/state/noctalia/settings.toml"

                echo "==> [1/5] Exporting Noctalia merged configuration via IPC..."
                noctalia config export > "$targetFile"; or begin
                    echo "Error: Failed to export config via noctalia IPC." >&2
                    return 1
                end

                echo "==> [2/5] Normalizing wallpaper paths and enforcing template suppression..."
                sed -i -E 's|directory = "[^"]*wallpapers"|directory = "/etc/wallpapers"|g' "$targetFile"
                sed -i -E 's|path = "[^"]*/wallpapers/([^"]+)"|path = "/etc/wallpapers/\1"|g' "$targetFile"

                if grep -q "\[theme\.templates\]" "$targetFile"
                    sed -i -E 's/enable_builtin_templates = true/enable_builtin_templates = false/g' "$targetFile"
                    sed -i -E 's/enable_community_templates = true/enable_community_templates = false/g' "$targetFile"
                else
                    printf '\n[theme.templates]\nenable_builtin_templates = false\nenable_community_templates = false\n' >> "$targetFile"
                end

                echo "==> [3/5] Staging changes in git..."
                git -C /etc/nixos add -A; or begin
                    echo "Error: Git staging failed." >&2
                    return 1
                end

                echo "==> [4/5] Rebuilding NixOS generation for host: $targetHost..."
                if sudo nixos-rebuild switch --flake "/etc/nixos#$targetHost"
                    echo "==> [5/5] Purging mutable runtime state override..."
                    rm -f "$stateFile"
                    echo "==> Noctalia declarative state synchronized and baked into system generation."
                else
                    echo "Error: nixos-rebuild failed. Runtime state preserved for recovery." >&2
                    return 1
                end
              '';
            };

            cfb = {
              description = "Generate structured LLM context snapshot without escaping bugs";
              body = ''
                set -l targetPath "."
                if test (count $argv) -ge 1
                    switch $argv[1]
                        case nix
                            set targetPath "/etc/nixos"
                        case cfg
                            set targetPath "$HOME/.config"
                        case '*'
                            set targetPath $argv[1]
                    end
                end

                set targetPath (realpath $targetPath 2>/dev/null; or echo $targetPath)
                if not test -d "$targetPath"
                    echo "Error: Target directory '$targetPath' does not exist." >&2
                    return 1
                end

                echo "Generating structured LLM context snapshot for: $targetPath..."

                set -l hostName (hostname 2>/dev/null; or echo "workstation")
                set -l userName (whoami 2>/dev/null; or echo "user")
                set -l dateString (date '+%Y-%m-%d %H:%M:%S')

                set -l outputStr "================================================================================
SYSTEM CONTEXT SNAPSHOT
Host: $hostName | User: $userName | Target: $targetPath | Date: $dateString
================================================================================

--------------------------------------------------------------------------------
DIRECTORY TOPOLOGY (including empty directories)
--------------------------------------------------------------------------------
"

                set -l extensions -e nix -e kdl -e toml -e conf -e ini -e el -e json -e fish -e zsh -e sh -e py -e css -e lua -e md
                set -l fdExcludes

                if string match -q "*.config*" "$targetPath"
                    set -l treeIgnores '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*|*.bin|*.dat|*asar*|*BraveSoftware*|*brave*|*chromium*|*floorp*|*librewolf*|*mozilla*|*google-chrome*|*obsidian*|*zennotes*'
                    set outputStr "$outputStr"(tree "$targetPath" -a -I "$treeIgnores" --noreport 2>/dev/null; or tree "$targetPath" -a -I '.git|result' --noreport)
                    set fdExcludes -E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*" -E "*asar" -E "*BraveSoftware*" -E "*brave*" -E "*chromium*" -E "*floorp*" -E "*librewolf*" -E "*mozilla*" -E "*google-chrome*" -E "*obsidian*" -E "*zennotes*"
                else
                    set outputStr "$outputStr"(tree "$targetPath" -a -I '.git|flake.lock|result|node_modules|target|*cache*|*Cache*|*.log|*.sqlite*|*.db*' --noreport 2>/dev/null; or tree "$targetPath" --noreport)
                    set fdExcludes -E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log" -E "*.sqlite*" -E "*.db*"
                end

                set outputStr "$outputStr

--------------------------------------------------------------------------------
FILE CONTENTS
--------------------------------------------------------------------------------
"

                set -l files (fd . "$targetPath" -t f -L -H -S -250k $extensions $fdExcludes 2>/dev/null)
                set -l fileCount (count $files)

                if test $fileCount -eq 0
                    set outputStr "$outputStr\n[No configuration files found matching extension filters.]\n"
                else
                    for file in $files
                        set -l relPath (string replace "$targetPath/" "" "$file")
                        set outputStr "$outputStr\n--- START OF FILE: $relPath ---\n"(cat "$file" 2>/dev/null)"\n--- END OF FILE: $relPath ---\n"
                    end
                end

                printf "%s" "$outputStr" | ${pkgs.wl-clipboard}/bin/wl-copy
                set -l byteSize (printf "%s" "$outputStr" | wc -c)
                set -l kilobyteSize (math -s0 "$byteSize / 1024")
                echo "[Copied context: Tree + $fileCount files ("$kilobyteSize" KB) from $targetPath to clipboard]"
              '';
            };
          };
        };
      };
    };
}
