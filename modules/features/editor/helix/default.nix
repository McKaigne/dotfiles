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
            default-yank-register = "+"
            line-number = "relative"
            mouse = false
            cursorline = true
            color-modes = true
            scrolloff = 5
            auto-save = true
            auto-format = true
            idle-timeout = 50
            completion-timeout = 5
            bufferline = "never"
            gutters = ["diagnostics", "line-numbers", "spacer", "diff"]

            [editor.statusline]
            left = ["mode", "file-name", "file-modification-indicator", "read-only-indicator"]
            center = []
            right = ["diagnostics", "selections", "position", "file-type"]
            separator = " "
            mode.normal = "NOR"
            mode.insert = "INS"
            mode.select = "SEL"

            [editor.cursor-shape]
            normal = "block"
            insert = "bar"
            select = "underline"

            [editor.indent-guides]
            render = false

            [editor.lsp]
            display-inlay-hints = false
            display-messages = true
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

            # Minimal Gutters & Relative Line Numbers
            "ui.linenr" = { fg = "surface1" }
            "ui.linenr.selected" = { fg = "lavender", modifiers = ["bold"] }
            "ui.gutter" = {}
            "ui.gutter.selected" = {}

            # Minimal Statusline with Pill Badges
            "ui.statusline" = { fg = "subtext0", bg = "mantle" }
            "ui.statusline.inactive" = { fg = "overlay0", bg = "mantle" }
            "ui.statusline.normal" = { fg = "crust", bg = "mauve", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "crust", bg = "green", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "crust", bg = "peach", modifiers = ["bold"] }
            "ui.statusline.separator" = { fg = "surface0" }

            # Overlays & Popups (Solid Surfaces for Code Readability)
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
