
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
      tmuxBin = "${pkgs.tmux}/bin/tmux";

      # Break mutual recursion: tmuxConf references sessionizer/picker by command name,
      # which are provided hermetically in wrappedTmux's PATH via $out/bin.
      tmuxConf = pkgs.writeText "tmux.conf" (builtins.replaceStrings
        [
          "@tmuxSessionizer@"
          "@tmuxWindowPicker@"
          "@lazygit@"
          "@superfile@"
          "@btop@"
          "@nu@"
          "@wlCopy@"
        ]
        [
          "tmux-sessionizer"
          "tmux-window-picker"
          "${pkgs.lazygit}/bin/lazygit"
          "${self'.packages.superfile}/bin/superfile"
          "${self'.packages.btop}/bin/btop"
          "${self'.packages.nushell}/bin/nu"
          "${pkgs.wl-clipboard}/bin/wl-copy"
        ]
        (builtins.readFile ./tmux.conf)
      );

      tmuxSessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.findutils pkgs.procps pkgs.coreutils pkgs.gnugrep pkgs.tmux ]}:$PATH"
        export TMUX_CONF="''${TMUX_CONF:-${tmuxConf}}"

        if [ $# -eq 1 ]; then
          selected="$1"
        else
          existing_sessions=$("${tmuxBin}" -f "$TMUX_CONF" list-sessions -F "#{session_name}" 2>/dev/null || true)
          search_roots=("$HOME/Projects" "$HOME/projects" "$HOME/work" "$HOME/personal" "$HOME/dotfiles" "/etc/nixos" "$HOME")
          existing_roots=()
          for r in "''${search_roots[@]}"; do
            [ -d "$r" ] && existing_roots+=("$r")
          done

          dirs=$(find "''${existing_roots[@]}" -mindepth 1 -maxdepth 1 -type d 2>/dev/null || true)
          selected=$( (echo "$existing_sessions"; echo "$dirs") | grep -v '^$' | fzf --reverse --prompt="󰒉 Sessions & Projects > " )
        fi

        [ -z "$selected" ] && exit 0

        if "${tmuxBin}" -f "$TMUX_CONF" has-session -t "$selected" 2>/dev/null; then
          if [ -z "''${TMUX:-}" ]; then
            exec "${tmuxBin}" -f "$TMUX_CONF" attach-session -t "$selected"
          else
            exec "${tmuxBin}" -f "$TMUX_CONF" switch-client -t "$selected"
          fi
        fi

        selected_name=$(basename "$selected" | tr . _)
        if ! "${tmuxBin}" -f "$TMUX_CONF" has-session -t "$selected_name" 2>/dev/null; then
          "${tmuxBin}" -f "$TMUX_CONF" new-session -ds "$selected_name" -c "$selected"
        fi

        if [ -z "''${TMUX:-}" ]; then
          exec "${tmuxBin}" -f "$TMUX_CONF" attach-session -t "$selected_name"
        else
          exec "${tmuxBin}" -f "$TMUX_CONF" switch-client -t "$selected_name"
        fi
      '';

      tmuxWindowPicker = pkgs.writeShellScriptBin "tmux-window-picker" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.coreutils pkgs.tmux ]}:$PATH"
        export TMUX_CONF="''${TMUX_CONF:-${tmuxConf}}"

        target=$("${tmuxBin}" -f "$TMUX_CONF" list-windows -a -F "#{session_name}:#{window_index} - #{window_name} #{?window_active,(active),}" 2>/dev/null | \
          fzf --reverse --prompt="󰖯 All Windows > " | cut -d' ' -f1)

        if [ -n "$target" ]; then
          "${tmuxBin}" -f "$TMUX_CONF" select-window -t "$target"
          "${tmuxBin}" -f "$TMUX_CONF" switch-client -t "$target"
        fi
      '';

      helixTmux = pkgs.writeShellScriptBin "helix-tmux" ''
        set -euo pipefail
        export TMUX_CONF="${tmuxConf}"
        exec "${tmuxBin}" -f "$TMUX_CONF" new-session -A -s main "${self'.packages.helix}/bin/hx" "$@"
      '';

      tmuxTermFocus = pkgs.writeShellScriptBin "tmux-term-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.ghostty pkgs.coreutils pkgs.tmux ]}:$PATH"
        export TMUX_CONF="${tmuxConf}"

        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "ghostty.tmux") or (.title | test("^tmux-terminal"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.ghostty}/bin/ghostty" --class="ghostty.tmux" --title="tmux-terminal" -e "${tmuxBin}" -f "$TMUX_CONF" new-session -A -s term
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

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [
          pkgs.tmux
          tmuxSessionizer
          tmuxWindowPicker
          helixTmux
          helixTmuxFocus
          tmuxTermFocus
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --prefix PATH : "${lib.makeBinPath [ pkgs.fzf pkgs.findutils pkgs.procps pkgs.lazygit pkgs.bat pkgs.wl-clipboard pkgs.jq pkgs.coreutils self'.packages.superfile self'.packages.helix self'.packages.nushell ]}:$out/bin" \
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
        meta.description = "Hermetically wrapped Tmux multiplexer with integrated sessionizer";
      };
    };
}
