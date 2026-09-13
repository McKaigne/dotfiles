{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-sessionizer
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux-window-picker
    ];
  };
in
{
  flake.nixosModules.tmux = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      tmuxSessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail
        PATH="${lib.makeBinPath [ pkgs.tmux pkgs.fzf pkgs.findutils pkgs.procps pkgs.coreutils pkgs.gnugrep ]}:$PATH"

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
        PATH="${lib.makeBinPath [ pkgs.tmux pkgs.fzf pkgs.coreutils ]}:$PATH"

        target=$(tmux list-windows -F "#{window_index}: #{window_name} #{?window_active,(active),}" 2>/dev/null | \
          fzf --reverse --prompt="󰖯 window > " --height=100% | \
          cut -d: -f1)

        if [ -n "$target" ]; then
          exec tmux select-window -t "$target"
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
        self'.packages.yazi
        self'.packages.helix
        self'.packages.nushell
        tmuxSessionizer
        tmuxWindowPicker
      ];

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [ pkgs.tmux tmuxSessionizer tmuxWindowPicker ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --prefix PATH : ${lib.makeBinPath tmuxDeps} \
            --set TMUX_CONF "${./tmux.conf}" \
            --add-flags "-f ${./tmux.conf}"
        '';
      };
    in
    {
      packages.tmux = wrappedTmux;
      packages.tmux-sessionizer = tmuxSessionizer;
      packages.tmux-window-picker = tmuxWindowPicker;

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
    };
}