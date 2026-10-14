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
            theme = "noctalia"

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

        xdg.configFile."helix/themes/solarized_osaka.toml" = {
          text = ''
            # Syntax Highlighting
            "attribute" = { fg = "blue300" }
            "keyword" = { fg = "green500" }
            "keyword.directive" = { fg = "red500" }
            "keyword.storage.modifier" = { fg = "green500" }
            "keyword.storage.type" = { fg = "green500" }
            "keyword.control.import" = { fg = "green500" }
            "keyword.function" = { fg = "green500" }
            "namespace" = { fg = "violet300" }
            "operator" = { fg = "green500" }
            "special" = { fg = "orange500" }
            "variable" = { fg = "base0" }
            "variable.builtin" = { fg = "orange500" }
            "variable.parameter" = { fg = "orange500" }
            "type" = { fg = "yellow300" }
            "type.builtin" = { fg = "yellow300", modifiers = ["bold"] }
            "constructor" = { fg = "orange500" }
            "function" = { fg = "blue500" }
            "function.macro" = { fg = "magenta900" }
            "function.builtin" = { fg = "blue900", modifiers = ["bold"] }
            "function.special" = { fg = "magenta900" }
            "comment" = { fg = "base01" }
            "string" = { fg = "cyan500" }
            "constant" = { fg = "cyan500" }
            "constant.builtin" = { fg = "cyan500", modifiers = ["bold"] }
            "constant.character" = { fg = "cyan500" }
            "constant.character.escape" = { fg = "red900", modifiers = ["bold"] }
            "label" = { fg = "green500" }
            "module" = { fg = "violet900" }
            "tag" = { fg = "green500" }
            "punctuation" = { fg = "orange500" }
            "punctuation.delimiter" = { fg = "green500" }
            "punctuation.bracket" = { fg = "orange500" }
            "punctuation.special" = { fg = "orange500" }
            "variable.other.member" = { fg = "blue500" }

            # Markup
            "markup.heading" = "green300"
            "markup.list" = "red300"
            "markup.bold" = { fg = "yellow500", modifiers = ["bold"] }
            "markup.italic" = { fg = "magenta300", modifiers = ["italic"] }
            "markup.strikethrough" = { modifiers = ["crossed_out"] }
            "markup.link.url" = { fg = "yellow300", modifiers = ["underlined"] }
            "markup.link.text" = "blue300"
            "markup.quote" = "cyan300"
            "markup.raw" = "green300"

            # Diff
            "diff.plus" = { fg = "green900" }
            "diff.delta" = { fg = "orange900" }
            "diff.minus" = { fg = "red900" }

            # Cursors & Selection
            "ui.cursor" = { fg = "base02", bg = "cyan900" }
            "ui.cursor.primary" = { fg = "base04", bg = "base1" }
            "ui.cursor.select" = { fg = "base02", bg = "cyan900" }
            "ui.cursor.insert" = { fg = "base04", bg = "base3" }
            "ui.cursor.match" = { fg = "base04", bg = "base00" }
            "ui.selection" = { bg = "base02" }
            "ui.selection.primary" = { bg = "base01" }

            "ui.virtual.indent-guide" = { fg = "base02" }
            "ui.virtual.ruler" = { fg = "red900" }
            "ui.virtual.whitespace" = { fg = "base01" }
            "ui.virtual.inlay-hint" = { fg = "base01", modifiers = ["italic"] }

            # Diagnostics
            "warning" = { fg = "orange500", modifiers = ["bold", "underlined"] }
            "error" = { fg = "red500", modifiers = ["bold", "underlined"] }
            "info" = { fg = "blue500", modifiers = ["bold", "underlined"] }
            "hint" = { fg = "base01", modifiers = ["bold", "underlined"] }

            "diagnostic.warning" = { fg = "yellow500", bg = "yellow900", underline = { style = "curl", color = "yellow500" } }
            "diagnostic.error" = { fg = "red500", bg = "red900", underline = { style = "curl", color = "red500" } }
            "diagnostic.info" = { fg = "blue500", bg = "blue900", underline = { style = "curl", color = "blue500" } }
            "diagnostic.hint" = { fg = "cyan500", bg = "cyan900", underline = { style = "curl", color = "cyan500" } }

            [palette]
            base04 = "#00141A"
            base03 = "#002B36"
            base02 = "#073642"
            base01 = "#586E75"
            base00 = "#657B83"
            base0 = "#9EACAD"
            base1 = "#ADB8B8"
            base2 = "#EEE8D5"
            base3 = "#FDF6E3"
            base4 = "#FFFFFF"

            yellow900 = "#332700"
            yellow700 = "#664D00"
            yellow500 = "#B58900"
            yellow300 = "#FFC100"
            yellow100 = "#FFE999"

            orange900 = "#5C220A"
            orange700 = "#A13C11"
            orange500 = "#CB4B16"
            orange300 = "#F8520E"
            orange100 = "#FF9468"

            red900 = "#57100F"
            red700 = "#B7211F"
            red500 = "#DC322F"
            red300 = "#F6524F"
            red100 = "#FF9D9B"

            magenta900 = "#541232"
            magenta700 = "#B02669"
            magenta500 = "#D33682"
            magenta300 = "#F255A1"
            magenta100 = "#FF77B9"

            violet900 = "#25285B"
            violet700 = "#494FB6"
            violet500 = "#6C71C4"
            violet300 = "#9CA0ED"
            violet100 = "#CCCFFF"

            blue900 = "#103956"
            blue700 = "#1B6497"
            blue500 = "#268BD2"
            blue300 = "#49AEF5"
            blue100 = "#AADCFF"

            cyan900 = "#103B3D"
            cyan700 = "#1A6265"
            cyan500 = "#2AA198"
            cyan300 = "#29EEDF"
            cyan100 = "#B9FFFA"

            green900 = "#2C3300"
            green700 = "#596600"
            green500 = "#859900"
            green300 = "#BAFB00"
            green100 = "#D6FFAC"
          '';
          force = true;
        };

        xdg.configFile."helix/themes/noctalia.toml" = {
          text = ''
            inherits = "solarized_osaka"

            # 100% Transparent Canvas
            "ui.background" = {}
            "ui.cursorline" = {}
            "ui.cursorline.primary" = {}
            "ui.cursorline.secondary" = {}

            # Line Numbers & Gutters (No Opaque Bars)
            "ui.linenr" = { fg = "base01" }
            "ui.linenr.selected" = { fg = "yellow500", modifiers = ["bold"] }
            "ui.gutter" = { fg = "base01" }
            "ui.gutter.selected" = { fg = "yellow500", modifiers = ["bold"] }

            # Statusline (Transparent Canvas with Colored Typography)
            "ui.statusline" = { fg = "base1" }
            "ui.statusline.inactive" = { fg = "base01" }
            "ui.statusline.normal" = { fg = "blue500", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "green500", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "yellow500", modifiers = ["bold"] }
            "ui.statusline.separator" = { fg = "base01" }

            # Bufferline Tabs (Transparent)
            "ui.bufferline" = { fg = "base01" }
            "ui.bufferline.active" = { fg = "base1", modifiers = ["bold"] }
            "ui.bufferline.background" = {}

            # Menus & Command Palette (:) - Completely Transparent
            "ui.menu" = { fg = "base1" }
            "ui.menu.selected" = { fg = "cyan300", modifiers = ["bold", "underlined"] }
            "ui.menu.scroll" = { fg = "base01" }

            # Popups & Which-Key (Space Menu) - Completely Transparent
            "ui.popup" = { fg = "base1" }
            "ui.popup.info" = { fg = "blue300", modifiers = ["bold"] }
            "ui.help" = { fg = "base0" }

            # File & Buffer Pickers (Space + f, Space + b)
            "ui.picker.header" = { fg = "cyan500", modifiers = ["bold"] }
            "ui.picker.header.column" = { fg = "cyan500", modifiers = ["bold"] }
            "ui.picker.header.column.active" = { fg = "blue300", modifiers = ["bold", "underlined"] }
            "ui.highlight" = { fg = "yellow300", modifiers = ["bold"] }

            # Window Split Borders
            "ui.window" = { fg = "base02" }

            # General Text Elements in UI
            "ui.text" = { fg = "base1" }
            "ui.text.focus" = { fg = "blue300", modifiers = ["bold"] }
            "ui.text.inactive" = { fg = "base01" }
            "ui.text.info" = { fg = "cyan500" }
          '';
          force = true;
        };
      };
    };
}
