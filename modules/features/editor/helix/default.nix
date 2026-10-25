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
        pkgs.lazygit
      ];

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix-wrapped";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${helixLspPath}"
          rm -f $out/bin/helix
          ln -sf hx $out/bin/helix
        '';
      };
    in
    {
      environment.systemPackages = [ wrappedHelix ];

      home-manager.users.${user} = {
        xdg.configFile."helix/languages.toml" = {
          text = ''
            [[language]]
            name = "nix"
            auto-format = true
            formatter = { command = "nixfmt" }
            language-servers = [ "nixd" ]
          '';
          force = true;
        };

        xdg.configFile."helix/config.toml" = {
          text = ''
            theme = "catppuccin_transparent"

            [editor]
            line-number = "relative"
            cursorline = true

            [editor.indent-guides]
            render = true
          '';
          force = true;
        };

        xdg.configFile."helix/themes/catppuccin_transparent.toml" = {
          text = ''
            inherits = "catppuccin_mocha"

            # Transparent Canvas & Cursorlines
            "ui.background" = {}
            "ui.cursorline" = {}
            "ui.cursorline.primary" = {}
            "ui.cursorline.secondary" = {}

            # Relative Line Numbers & Minimal Gutters
            "ui.linenr" = { fg = "surface1" }
            "ui.linenr.selected" = { fg = "lavender", modifiers = ["bold"] }
            "ui.gutter" = {}
            "ui.gutter.selected" = {}

            # Vertical Indentation Guide Lines
            "ui.indent-guide" = { fg = "surface0" }
            "ui.indent-guide.active" = { fg = "surface2" }

            # Overlays & Popups
            "ui.popup" = { fg = "text", bg = "surface0" }
            "ui.popup.info" = { fg = "blue", modifiers = ["bold"] }
            "ui.help" = { fg = "subtext1", bg = "surface0" }

            "ui.menu" = { fg = "text", bg = "surface0" }
            "ui.menu.selected" = { fg = "crust", bg = "mauve", modifiers = ["bold"] }
            "ui.menu.scroll" = { fg = "surface2", bg = "surface0" }

            "ui.window" = { fg = "surface0" }
          '';
          force = true;
        };
      };
    };
}
