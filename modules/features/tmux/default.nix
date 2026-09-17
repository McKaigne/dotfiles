{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-sessionizer
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-window-picker
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix-tmux
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix-tmux-focus
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-term-focus
    ];
  };
in
{
  flake.nixosModules.tmux = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      tmuxConf = ./tmux.conf;

      # Sessionizer wrapped to ALWAYS invoke tmux with the hermetic config
      tmuxSessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.findutils pkgs.procps pkgs.coreutils pkgs.gnugrep ]}:$PATH"
        TMUX_CONF="${tmuxConf}"
        export TMUX_CONF

        tmux() {
          command "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" "$@"
        }

        if [ $# -eq 1 ]; then
          selected="$1"
        else
          existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)

          search_roots=("$HOME/projects" "$HOME/work" "$HOME/personal" "$HOME/dotfiles" "/etc/nixos" "$HOME")
          existing_roots=()
          for r in "''${search_roots[@]}"; do
            [ -d "$r" ] && existing_roots+=("$r")
          done

          dirs=$(find "''${existing_roots[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)

          selected=$( (echo "$existing_sessions"; echo "$dirs") | grep -v '^$' | fzf --reverse --prompt="󰒉 Sessionizer > " --height=100% )
        fi

        if [ -z "$selected" ]; then
          exit 0
        fi

        if tmux has-session -t "$selected" 2>/dev/null; then
          if [ -z "''${TMUX:-}" ]; then
            exec tmux attach-session -t "$selected"
          else
            exec tmux switch-client -t "$selected"
          fi
        fi

        selected_name=$(basename "$selected" | tr . _)

        if ! tmux has-session -t "$selected_name" 2>/dev/null; then
          tmux new-session -ds "$selected_name" -c "$selected"
        fi

        if [ -z "''${TMUX:-}" ]; then
          exec tmux attach-session -t "$selected_name"
        else
          exec tmux switch-client -t "$selected_name"
        fi
      '';

      tmuxWindowPicker = pkgs.writeShellScriptBin "tmux-window-picker" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.coreutils ]}:$PATH"
        TMUX_CONF="${tmuxConf}"

        tmux() {
          command "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" "$@"
        }

        target=$(tmux list-windows -F "#{window_index}: #{window_name} #{?window_active,(active),}" 2>/dev/null | \
          fzf --reverse --prompt="󰖯 window > " --height=100% | \
          cut -d: -f1)

        if [ -n "$target" ]; then
          exec tmux select-window -t "$target"
        fi
      '';

      # Raw Helix launcher attached to a persistent 'main' session
      helixTmux = pkgs.writeShellScriptBin "helix-tmux" ''
        set -euo pipefail
        TMUX_CONF="${tmuxConf}"
        export TMUX_CONF
        exec "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" new-session -A -s main "${self'.packages.helix}/bin/hx" "$@"
      '';

      # Focus-or-Spawn for Tmux terminal (Mod + T)
      tmuxTermFocus = pkgs.writeShellScriptBin "tmux-term-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.ghostty pkgs.coreutils ]}:$PATH"
        TMUX_CONF="${tmuxConf}"
        export TMUX_CONF

        # Check if an existing tmux-terminal window is open in Niri
        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "ghostty.tmux") or (.title | test("^tmux-terminal"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.ghostty}/bin/ghostty" --class="ghostty.tmux" --title="tmux-terminal" -e "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" new-session -A -s term
        fi
      '';

      # Focus-or-Spawn for Helix in Tmux (Mod + D)
      helixTmuxFocus = pkgs.writeShellScriptBin "helix-tmux-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.ghostty pkgs.coreutils ]}:$PATH"

        # Check if an existing helix-tmux window is open in Niri
        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "ghostty.helix") or (.title | test("^helix-tmux"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.ghostty}/bin/ghostty" --class="ghostty.helix" --title="helix-tmux" -e "${helixTmux}/bin/helix-tmux"
        fi
      '';

      tmuxDeps = [
        pkgs.fzf
        pkgs.findutils
        pkgs.procps
        pkgs.lazygit
        pkgs.python3
        pkgs.btop
        pkgs.wl-clipboard
        pkgs.jq
        self'.packages.yazi
        self'.packages.helix
        self'.packages.nushell
        tmuxSessionizer
        tmuxWindowPicker
        helixTmux
        helixTmuxFocus
        tmuxTermFocus
      ];

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [ pkgs.tmux tmuxSessionizer tmuxWindowPicker helixTmux helixTmuxFocus tmuxTermFocus ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --prefix PATH : ${lib.makeBinPath tmuxDeps} \
            --set TMUX_CONF "${tmuxConf}" \
            --add-flags "-f ${tmuxConf}"
        '';
      };
    in
    {
      packages.tmux = wrappedTmux;
      packages.tmux-sessionizer = tmuxSessionizer;
      packages.tmux-window-picker = tmuxWindowPicker;
      packages.helix-tmux = helixTmux;
      packages.helix-tmux-focus = helixTmuxFocus;
      packages.tmux-term-focus = tmuxTermFocus;

      apps.tmux = {
        type = "app";
        program = "${wrappedTmux}/bin/tmux";
        meta.description = "Hermetically wrapped Tmux terminal multiplexer";
      };
      apps.tmux-sessionizer = {
        type = "app";
        program = "${tmuxSessionizer}/bin/tmux-sessionizer";
        meta.description = "ThePrimeagen's tmux-sessionizer project manager";
      };
      apps.tmux-window-picker = {
        type = "app";
        program = "${tmuxWindowPicker}/bin/tmux-window-picker";
        meta.description = "Interactive fzf window switcher for tmux";
      };
      apps.helix-tmux = {
        type = "app";
        program = "${helixTmux}/bin/helix-tmux";
        meta.description = "Launch persistent Helix modal editor inside Tmux";
      };
      apps.helix-tmux-focus = {
        type = "app";
        program = "${helixTmuxFocus}/bin/helix-tmux-focus";
        meta.description = "Focus or spawn persistent Helix modal editor inside Tmux";
      };
      apps.tmux-term-focus = {
        type = "app";
        program = "${tmuxTermFocus}/bin/tmux-term-focus";
        meta.description = "Focus or spawn persistent Tmux terminal session";
      };
    };
}