{ self, inputs, ... }: {
  flake.nixosModules.helix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      helixLspPath = lib.makeBinPath [
        pkgs.marksman
        pkgs.nixd
        pkgs.nixfmt
        pkgs.bash-language-server
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.taplo
        pkgs.yaml-language-server
      ];

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix-wrapped";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${helixLspPath}"
          [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
        '';
      };
    in
    {
      environment.systemPackages = [ wrappedHelix ];

      home-manager.users.${user} = {
        xdg.configFile."helix/config.toml".text = ''
          theme = "noctalia"

          [editor]
          line-number = "relative"
          mouse = false
          cursorline = false
          color-modes = true
          scrolloff = 5
          auto-save = true
          auto-format = true
          idle-timeout = 50
          completion-timeout = 5
          bufferline = "multiple"
          gutters = ["diagnostics", "spacer", "line-numbers", "spacer", "diff"]

          [editor.cursor-shape]
          normal = "block"
          insert = "bar"
          select = "underline"

          [editor.indent-guides]
          render = true
          character = "│"
          skip-levels = 1

          [editor.soft-wrap]
          enable = true
          wrap-indicator = ""

          [editor.lsp]
          display-inlay-hints = true
          display-messages = true

          [editor.statusline]
          left = ["mode", "spinner", "file-name", "read-only-indicator", "file-modification-indicator"]
          center = []
          right = ["diagnostics", "selections", "position", "file-type"]
          separator = "│"
          mode.normal = "NORMAL"
          mode.insert = "INSERT"
          mode.select = "SELECT"
        '';
      };
    };
}
