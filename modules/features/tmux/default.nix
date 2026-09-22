{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-sessionizer
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-window-picker
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-helix-picker
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
      tmuxSessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.findutils pkgs.procps pkgs.coreutils pkgs.gnugrep pkgs.tmux ]}:$PATH"

        tmux() {
          command "${pkgs.tmux}/bin/tmux" ''${TMUX_CONF:+-f "$TMUX_CONF"} "$@"
        }

        if [ $# -eq 1 ]; then
          selected="$1"
        else
          existing_sessions=$(tmux list-sessions -F "#{session_name}" 2>/dev/null || true)

          search_roots=("$HOME/Projects" "$HOME/projects" "$HOME/work" "$HOME/personal" "$HOME/dotfiles" "/etc/nixos" "$HOME")
          existing_roots=()
          for r in "''${search_roots[@]}"; do
            [ -d "$r" ] && existing_roots+=("$r")
          done

          dirs=$(find "''${existing_roots[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)

          selected=$( (echo "$existing_sessions"; echo "$dirs") | grep -v '^$' | fzf --reverse --prompt="󰒉 Sessions & Projects > " )
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
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.tmux pkgs.coreutils ]}:$PATH"

        target=$(tmux list-windows -a -F "#{session_name}:#{window_index} - #{window_name} #{?window_active,(active),}" 2>/dev/null | \
          fzf --reverse --prompt="󰖯 All Windows > " | cut -d' ' -f1)

        if [ -n "$target" ]; then
          tmux select-window -t "$target"
          tmux switch-client -t "$target"
        fi
      '';

      tmuxHelixPicker = pkgs.writeShellScriptBin "tmux-helix-picker" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.tmux pkgs.gnugrep pkgs.coreutils ]}:$PATH"

        target=$(tmux list-panes -a -F '#{session_name}:#{window_index}.#{pane_index} │ #{pane_current_command} │ #{window_name} │ #{pane_current_path}' 2>/dev/null | \
          grep -Ei '(hx|helix)' | \
          fzf --reverse --prompt="󰅩 Helix Panes > " --header="Select active Helix session" | \
          cut -d'│' -f1 | tr -d ' ')

        if [ -n "$target" ]; then
          tmux select-pane -t "$target"
          tmux select-window -t "$target"
          tmux switch-client -t "$target"
        fi
      '';

      tmuxConf = pkgs.writeText "tmux.conf" (builtins.replaceStrings
        [
          "@nnn@"
          "@tmuxSessionizer@"
          "@tmuxWindowPicker@"
          "@tmuxHelixPicker@"
          "@lazygit@"
          "@superfile@"
          "@btop@"
          "@nu@"
          "@wlCopy@"
        ]
        [
          "${pkgs.nnn}/bin/nnn"
          "${tmuxSessionizer}/bin/tmux-sessionizer"
          "${tmuxWindowPicker}/bin/tmux-window-picker"
          "${tmuxHelixPicker}/bin/tmux-helix-picker"
          "${pkgs.lazygit}/bin/lazygit"
          "${self'.packages.superfile}/bin/superfile"
          "${self'.packages.btop}/bin/btop"
          "${self'.packages.nushell}/bin/nu"
          "${pkgs.wl-clipboard}/bin/wl-copy"
        ]
        (builtins.readFile ./tmux.conf)
      );

      helixTmux = pkgs.writeShellScriptBin "helix-tmux" ''
        set -euo pipefail
        TMUX_CONF="${tmuxConf}"
        export TMUX_CONF
        exec "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" new-session -A -s main "${self'.packages.helix}/bin/hx" "$@"
      '';

      tmuxTermFocus = pkgs.writeShellScriptBin "tmux-term-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.ghostty pkgs.coreutils ]}:$PATH"
        TMUX_CONF="${tmuxConf}"
        export TMUX_CONF

        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "ghostty.tmux") or (.title | test("^tmux-terminal"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.ghostty}/bin/ghostty" --class="ghostty.tmux" --title="tmux-terminal" -e "${pkgs.tmux}/bin/tmux" -f "$TMUX_CONF" new-session -A -s term
        fi
      '';

      helixTmuxFocus = pkgs.writeShellScriptBin "helix-tmux-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.ghostty pkgs.coreutils ]}:$PATH"

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
        pkgs.nnn
        self'.packages.superfile
        self'.packages.helix
        self'.packages.nushell
        tmuxSessionizer
        tmuxWindowPicker
        tmuxHelixPicker
        helixTmux
        helixTmuxFocus
        tmuxTermFocus
      ];

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [
          pkgs.tmux
          tmuxSessionizer
          tmuxWindowPicker
          tmuxHelixPicker
          helixTmux
          helixTmuxFocus
          tmuxTermFocus
        ];
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
      packages.tmux-helix-picker = tmuxHelixPicker;
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
    };
}