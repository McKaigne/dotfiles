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
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      tmuxCheatsheet = pkgs.writeShellScriptBin "tmux-cheatsheet" ''
        cat << 'EOF' | ${pkgs.bat}/bin/bat --style=plain --paging=always -l yaml
        === TMUX KEYBOARD CHEATSHEET ===

        1. PANES & SPLITS (Zero-Prefix Alt)
           Alt + h / j / k / l   : Focus Left / Down / Up / Right pane
           Alt + v               : Split pane vertically (right)
           Alt + z               : Toggle zoom pane (fullscreen)
           Alt + q               : Close active pane

        2. TABS & SESSIONS (No-Gaps Alt + Ctrl)
           Alt + t               : New tab in current directory
           Alt + Ctrl + j        : Next tab (window)
           Alt + Ctrl + k        : Previous tab (window)
           Alt + Ctrl + q        : Close active tab (window)
           Alt + 1..0            : Jump directly to Tab 1-10

        3. FLOATING POPUPS (Zero-Prefix Alt)
           Alt + e               : nnn file manager in pane directory
           Alt + b               : Fuzzy Window / Tab picker
           Alt + a               : Project switcher (tmux-sessionizer)
           Alt + g               : Lazygit git client
           Alt + m               : Btop system resource monitor
           Alt + Enter           : Floating Nushell scratchpad
           Alt + /               : Open this cheatsheet

        4. PREFIX TOOLS (Prefix = Ctrl+b or Kanata n+m)
           Prefix + s            : Split horizontally (Leaves Alt+s for Helix!)
           Prefix + c            : Enter Emacs-style copy mode
           Prefix + h            : Active Helix panes picker
           Prefix + /            : Open this cheatsheet
           Prefix + r            : Reload config from Nix store

        5. COPY MODE (Inside Copy Mode)
           Space / v             : Start selection
           M-w / y / Enter       : Copy to system clipboard (wl-copy)
           C-g / Escape / q      : Cancel / Exit copy mode
           M-v / C-v             : Page Up / Page Down
           C-s / /               : Search history
        EOF
      '';

      tmuxConf = pkgs.writeText "tmux.conf" (builtins.replaceStrings
        [
          "@nnn@"
          "@tmuxSessionizer@"
          "@tmuxWindowPicker@"
          "@tmuxHelixPicker@"
          "@tmuxCheatsheet@"
          "@lazygit@"
          "@superfile@"
          "@btop@"
          "@nu@"
          "@wlCopy@"
        ]
        [
          "${pkgs.nnn}/bin/nnn"
          "/run/current-system/sw/bin/tmux-sessionizer"
          "/run/current-system/sw/bin/tmux-window-picker"
          "/run/current-system/sw/bin/tmux-helix-picker"
          "${tmuxCheatsheet}/bin/tmux-cheatsheet"
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
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.findutils pkgs.procps pkgs.coreutils pkgs.gnugrep ]}:/run/current-system/sw/bin:$PATH"
        export TMUX_CONF="''${TMUX_CONF:-${tmuxConf}}"

        if [ $# -eq 1 ]; then
          selected="$1"
        else
          existing_sessions=$(tmux -f "$TMUX_CONF" list-sessions -F "#{session_name}" 2>/dev/null || true)
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

        if tmux -f "$TMUX_CONF" has-session -t "$selected" 2>/dev/null; then
          if [ -z "''${TMUX:-}" ]; then
            exec tmux -f "$TMUX_CONF" attach-session -t "$selected"
          else
            exec tmux -f "$TMUX_CONF" switch-client -t "$selected"
          fi
        fi

        selected_name=$(basename "$selected" | tr . _)

        if ! tmux -f "$TMUX_CONF" has-session -t "$selected_name" 2>/dev/null; then
          tmux -f "$TMUX_CONF" new-session -ds "$selected_name" -c "$selected"
        fi

        if [ -z "''${TMUX:-}" ]; then
          exec tmux -f "$TMUX_CONF" attach-session -t "$selected_name"
        else
          exec tmux -f "$TMUX_CONF" switch-client -t "$selected_name"
        fi
      '';

      tmuxWindowPicker = pkgs.writeShellScriptBin "tmux-window-picker" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.coreutils ]}:/run/current-system/sw/bin:$PATH"
        export TMUX_CONF="''${TMUX_CONF:-${tmuxConf}}"

        target=$(tmux -f "$TMUX_CONF" list-windows -a -F "#{session_name}:#{window_index} - #{window_name} #{?window_active,(active),}" 2>/dev/null | \
          fzf --reverse --prompt="󰖯 All Windows > " | cut -d' ' -f1)

        if [ -n "$target" ]; then
          tmux -f "$TMUX_CONF" select-window -t "$target"
          tmux -f "$TMUX_CONF" switch-client -t "$target"
        fi
      '';

      tmuxHelixPicker = pkgs.writeShellScriptBin "tmux-helix-picker" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.fzf pkgs.gnugrep pkgs.coreutils ]}:/run/current-system/sw/bin:$PATH"
        export TMUX_CONF="''${TMUX_CONF:-${tmuxConf}}"

        target=$(tmux -f "$TMUX_CONF" list-panes -a -F "#{session_name}:#{window_index}.#{pane_index} │ #{pane_current_command} │ #{window_name} │ #{pane_current_path}" 2>/dev/null | \
          grep -Ei '(hx|helix)' | \
          fzf --reverse --prompt="󰅩 Helix Panes > " --header="Select active Helix session" | \
          cut -d'│' -f1 | tr -d ' ')

        if [ -n "$target" ]; then
          tmux -f "$TMUX_CONF" select-pane -t "$target"
          tmux -f "$TMUX_CONF" select-window -t "$target"
          tmux -f "$TMUX_CONF" switch-client -t "$target"
        fi
      '';

      helixTmux = pkgs.writeShellScriptBin "helix-tmux" ''
        set -euo pipefail
        export TMUX_CONF="${tmuxConf}"
        exec /run/current-system/sw/bin/tmux -f "$TMUX_CONF" new-session -A -s main "${self'.packages.helix}/bin/hx" "$@"
      '';

      tmuxTermFocus = pkgs.writeShellScriptBin "tmux-term-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.foot pkgs.coreutils ]}:/run/current-system/sw/bin:$PATH"
        export TMUX_CONF="${tmuxConf}"

        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "foot.tmux") or (.title | test("^tmux-terminal"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.foot}/bin/foot" --app-id="foot.tmux" --title="tmux-terminal" -e /run/current-system/sw/bin/tmux -f "$TMUX_CONF" new-session -A -s term
        fi
      '';

      helixTmuxFocus = pkgs.writeShellScriptBin "helix-tmux-focus" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.jq pkgs.niri self'.packages.foot pkgs.coreutils ]}:/run/current-system/sw/bin:$PATH"

        WINDOW_ID=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id == "foot.helix") or (.title | test("^helix-tmux"; "i"))) | .id' | head -n1 || true)

        if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
          niri msg action focus-window --id "$WINDOW_ID"
        else
          exec "${self'.packages.foot}/bin/foot" --app-id="foot.helix" --title="helix-tmux" -e "${helixTmux}/bin/helix-tmux"
        fi
      '';

      tmuxDeps = [
        pkgs.fzf
        pkgs.findutils
        pkgs.procps
        pkgs.lazygit
        pkgs.python3
        pkgs.btop
        pkgs.bat
        pkgs.wl-clipboard
        pkgs.jq
        pkgs.nnn
        pkgs.coreutils
        pkgs.util-linux
        self'.packages.superfile
        self'.packages.helix
        self'.packages.nushell
        tmuxCheatsheet
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
          tmuxCheatsheet
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