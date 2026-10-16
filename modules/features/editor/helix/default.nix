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
            line-number = "relative"
            mouse = false
            cursorline = true
            color-modes = true
            scrolloff = 5
            auto-save = true
            auto-format = true
            idle-timeout = 50
            completion-timeout = 5
            bufferline = "always"
            gutters = ["diagnostics", "line-numbers", "spacer", "diff"]

            [editor.cursor-shape]
            normal = "block"
            insert = "bar"
            select = "underline"

            [editor.indent-guides]
            render = true
            character = "│"
            skip-levels = 1

            [editor.inline-diagnostics]
            cursor-line = "warning"

            [editor.whitespace]
            render = { space = "none", tab = "all", newline = "none" }
            characters = { tab = "→", tabpad = " " }

            [editor.soft-wrap]
            enable = true
            wrap-indicator = ""

            [editor.lsp]
            display-inlay-hints = true
            display-messages = true
          '';
          force = true;
        };

        xdg.configFile."helix/themes/catppuccin_transparent.toml" = {
          text = ''
            inherits = "catppuccin_mocha"

            "ui.background" = {}
            "ui.cursorline" = {}
            "ui.cursorline.primary" = {}
            "ui.cursorline.secondary" = {}

            "ui.linenr" = { fg = "surface1" }
            "ui.linenr.selected" = { fg = "mauve", modifiers = ["bold"] }
            "ui.gutter" = { fg = "surface1" }
            "ui.gutter.selected" = { fg = "mauve", modifiers = ["bold"] }

            "ui.statusline" = { fg = "text", bg = "mantle" }
            "ui.statusline.inactive" = { fg = "overlay0", bg = "mantle" }
            "ui.statusline.normal" = { fg = "crust", bg = "mauve", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "crust", bg = "green", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "crust", bg = "peach", modifiers = ["bold"] }
            "ui.statusline.separator" = { fg = "surface2" }

            "ui.bufferline" = { fg = "overlay0" }
            "ui.bufferline.active" = { fg = "text", modifiers = ["bold"] }
            "ui.bufferline.background" = {}

            "ui.menu" = { fg = "text", bg = "surface0" }
            "ui.menu.selected" = { fg = "teal", bg = "surface1", modifiers = ["bold"] }
            "ui.menu.scroll" = { fg = "surface2" }

            "ui.popup" = { fg = "text", bg = "surface0" }
            "ui.popup.info" = { fg = "blue", modifiers = ["bold"] }
            "ui.help" = { fg = "subtext1", bg = "surface0" }

            "ui.picker.header" = { fg = "teal", modifiers = ["bold"] }
            "ui.picker.header.column" = { fg = "teal", modifiers = ["bold"] }
            "ui.picker.header.column.active" = { fg = "blue", modifiers = ["bold", "underlined"] }
            "ui.highlight" = { fg = "yellow", modifiers = ["bold"] }

            "ui.window" = { fg = "surface0" }

            "ui.text" = { fg = "text" }
            "ui.text.focus" = { fg = "blue", modifiers = ["bold"] }
            "ui.text.inactive" = { fg = "overlay0" }
            "ui.text.info" = { fg = "teal" }
          '';
          force = true;
        };
      };
    };
}
