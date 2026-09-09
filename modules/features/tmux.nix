{ self, ... }: {
  flake.nixosModules.tmux = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
    ];
  };

  perSystem = { pkgs, ... }:
    let
      tmuxConf = pkgs.writeText "tmux.conf" ''
        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"
        set -g mouse on

        set -g status-style bg=default
        set -g status-position bottom

        set -g @tmux-dotbar-bg "default"
        set -g @tmux-dotbar-fg-session "cyan"
        set -g @tmux-dotbar-fg-current "green"
        set -g @tmux-dotbar-fg-prefix "magenta"

        run-shell ${pkgs.tmuxPlugins.dotbar}/share/tmux-plugins/dotbar/dotbar.tmux
      '';

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [ pkgs.tmux ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --add-flags "-f ${tmuxConf}"
        '';
      };
    in
    {
      packages.tmux = wrappedTmux;

      apps.tmux = {
        type = "app";
        program = "${wrappedTmux}/bin/tmux";
        meta.description = "Hermetically wrapped Tmux terminal multiplexer";
      };
    };
}