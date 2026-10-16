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
            bufferline = "multiple"
            gutters = ["diagnostics", "line-numbers", "diff"]

            [editor.statusline]
            left = ["mode", "spinner", "file-name", "file-modification-indicator"]
            center = []
            right = ["diagnostics", "selections", "position", "file-type"]
            separator = " │ "
            mode.normal = "NORMAL"
            mode.insert = "INSERT"
            mode.select = "SELECT"

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

            # 100% Transparent Canvas & Cursorlines
            "ui.background" = {}
            "ui.cursorline" = {}
            "ui.cursorline.primary" = {}
            "ui.cursorline.secondary" = {}

            # Flat Gutters & Line Numbers (No Background Highlights)
            "ui.linenr" = { fg = "surface1" }
            "ui.linenr.selected" = { fg = "mauve", modifiers = ["bold"] }
            "ui.gutter" = { fg = "surface1" }
            "ui.gutter.selected" = { fg = "mauve", modifiers = ["bold"] }

            # Pure Typographic Statusline (Zero Background Fills, Zero Capsules)
            "ui.statusline" = { fg = "text" }
            "ui.statusline.inactive" = { fg = "overlay0" }
            "ui.statusline.normal" = { fg = "mauve", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "green", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "peach", modifiers = ["bold"] }
            "ui.statusline.separator" = { fg = "surface1" }

            # Borderless Tab Typography (No Boxes, Transparent Strip)
            "ui.bufferline" = { fg = "overlay0" }
            "ui.bufferline.active" = { fg = "text", modifiers = ["bold"] }
            "ui.bufferline.background" = {}

            # Floating Overlays (Flat Solid Surface for Readability Over Code)
            "ui.popup" = { fg = "text", bg = "surface0" }
            "ui.popup.info" = { fg = "blue", modifiers = ["bold"] }
            "ui.help" = { fg = "subtext1", bg = "surface0" }

            "ui.menu" = { fg = "text", bg = "surface0" }
            "ui.menu.selected" = { fg = "teal", bg = "surface1", modifiers = ["bold"] }
            "ui.menu.scroll" = { fg = "surface2" }

            "ui.window" = { fg = "surface0" }
          '';
          force = true;
        };
      };
    };
}
