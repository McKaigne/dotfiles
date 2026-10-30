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
      safeAbbrs = lib.filterAttrs (_: cmd: !isFlag cmd) config.workstation.shellAbbrs;
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

            set -gx LS_COLORS (${pkgs.vivid}/bin/vivid generate catppuccin-mocha)



            abbr --add ntrace -- --show-trace
          '';

          interactiveShellInit = ''
            if test "$TERM" != dumb
                ${pkgs.starship}/bin/starship init fish | source
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
                ${pkgs.gnused}/bin/sed -i -E 's|path = "[^"]*/wallpapers/([^"]+)"|path = "/etc/wallpapers/\\1"|g' "$tmpFile"

                if ${pkgs.gnugrep}/bin/grep -q "\[theme\.templates\]" "$tmpFile"
                    ${pkgs.gnused}/bin/sed -i -E 's/enable_builtin_templates = true/enable_builtin_templates = false/g' "$tmpFile"
                    ${pkgs.gnused}/bin/sed -i -E 's/enable_community_templates = true/enable_community_templates = false/g' "$tmpFile"
                else
                    printf '\n[theme.templates]\nenable_builtin_templates = false\nenable_community_templates = false\n' >> "$tmpFile"
                end

                mv -f "$tmpFile" "$targetFile"

                echo "==> [3/5] Staging changes in git..."
                if not git -C /etc/nixos add -A
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
