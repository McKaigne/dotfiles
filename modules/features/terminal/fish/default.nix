_: {
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
      safeAbbrs = lib.filterAttrs (_: cmd: !isFlag cmd) config.workstation.shellAbbrs;
      lsColors = pkgs.runCommand "vivid-ls-colors" { } "${pkgs.vivid}/bin/vivid generate catppuccin-mocha > $out";
    in
    {
      programs.fish.enable = true;
      users.users.${user}.shell = pkgs.fish;

      home-manager.users.${user} = {
        programs.fish = {
          enable = true;
          shellAliases = { };
          shellAbbrs = safeAbbrs;

          shellInit = ''
            set -g fish_greeting ""
            set -gx STARSHIP_CONFIG "/etc/starship.toml"

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

            abbr --add ntrace -- --show-trace
          '';

          interactiveShellInit = ''
            fish_vi_key_bindings
            set fish_cursor_default block
            set fish_cursor_insert line
            set fish_cursor_replace_one underscore
            set fish_cursor_visual block

            # Alt-e and Ctrl-x Ctrl-e open current buffer in Helix
            bind -M insert e edit_command_buffer
            bind -M default e edit_command_buffer
            bind -M insert \cx\ce edit_command_buffer
            bind -M default \cx\ce edit_command_buffer

            if test "$TERM" != dumb
                set -gx LS_COLORS (cat ${lsColors})
                ${pkgs.starship}/bin/starship init fish | source
                ${pkgs.carapace}/bin/carapace _carapace fish | source
            end
          '';

          functions = {
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

            clast = {
              description = "Re-run last command and copy its output to clipboard";
              body = ''
                set -l cmd (history --max 1)
                if test -n "$cmd"
                    eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
                    and echo "Copied output of '$cmd' to clipboard."
                end
              '';
            };

            chist = {
              description = "Interactively select a historical command and copy its output";
              body = ''
                set -l cmd (history | ${pkgs.fzf}/bin/fzf --reverse --header="Select command to copy output to clipboard:")
                if test -n "$cmd"
                    eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
                    and echo "Copied output of '$cmd' to clipboard."
                end
              '';
            };

            nsync = {
              description = "Synchronize Noctalia runtime GUI state to declarative base";
              body = ''
                set -l targetHost (hostname 2>/dev/null; or echo "hyde")
                set -l targetFile "/etc/nixos/modules/features/desktop/noctalia/noctalia.toml"
                set -l stateFile "$HOME/.local/state/noctalia/settings.toml"
                set -l tmpFile (mktemp)

                echo "==> [1/5] Exporting Noctalia merged configuration via IPC..."
                if not noctalia config export > "$tmpFile"
                    echo "Error: Failed to export config via noctalia IPC." >&2
                    rm -f "$tmpFile"
                    return 1
                end

                echo "==> [2/5] Normalizing wallpaper paths and enforcing template suppression..."
                ${pkgs.gnused}/bin/sed -i -E 's|directory = "[^"]*wallpapers"|directory = "/etc/wallpapers"|g' "$tmpFile"
                ${pkgs.gnused}/bin/sed -i -E 's|path = "[^"]*/wallpapers/([^"]+)"|path = "/etc/wallpapers/\1"|g' "$tmpFile"

                if ${pkgs.gnugrep}/bin/grep -q "\[theme\.templates\]" "$tmpFile"
                    ${pkgs.gnused}/bin/sed -i -E 's/enable_builtin_templates = true/enable_builtin_templates = false/g' "$tmpFile"
                    ${pkgs.gnused}/bin/sed -i -E 's/enable_community_templates = true/enable_community_templates = false/g' "$tmpFile"
                else
                    printf "
[theme.templates]
enable_builtin_templates = false
enable_community_templates = false
" >> "$tmpFile"
                end

                mv -f "$tmpFile" "$targetFile"

                echo "==> [3/5] Staging changes in git..."
                if not git -C /etc/nixos add -A
                    echo "Error: Git staging failed." >&2
                    return 1
                end

                echo "==> [4/5] Rebuilding NixOS generation for host: $targetHost..."
                if nh os switch --flake "/etc/nixos#$targetHost"
                    echo "==> [5/5] Purging mutable runtime state override..."
                    rm -f "$stateFile"
                    echo "==> Noctalia declarative state synchronized and baked into system generation."
                else
                    echo "Error: nh os switch failed. Runtime state preserved for recovery." >&2
                    return 1
                end
              '';
            };
          };
        };
      };
    };
}
