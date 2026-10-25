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
      isFlag = cmd: lib.hasPrefix "-" cmd;
      safeAliases = lib.filterAttrs (_: cmd: !isFlag cmd) config.workstation.shellAliases;
      safeAbbrs = lib.filterAttrs (_: cmd: !isFlag cmd) config.workstation.shellAbbrs;
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
        gawk
        tree
        fd
      ];

      home-manager.users.${user} = {
        programs.fish = {
          enable = true;
          shellAliases = safeAliases;
          shellAbbrs = safeAbbrs;

          shellInit = ''
            set -g fish_greeting ""

            fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin

            # Catppuccin Mocha LS_COLORS
            set -gx LS_COLORS (${pkgs.vivid}/bin/vivid generate catppuccin-mocha)

            # Catppuccin Mocha Syntax Palette
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

            # Terminate flag evaluation cleanly
            abbr --add ntrace -- --show-trace
          '';

          functions = {
            writefile = {
              description = "Write raw stdin to file until delimiter without parsing errors";
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
              description = "Append raw stdin to file until delimiter without parsing errors";
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
          };
        };
      };
    };
}
