_: {
  flake.nixosModules.helix =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      home-manager.users.${user} = {
        programs.helix = {
          enable = true;
          defaultEditor = true;
          extraPackages = with pkgs; [
            wl-clipboard
            # Nix
            nixd
            nixfmt
            # Config & Markup
            marksman
            taplo
            yaml-language-server
            # Shell scripting
            bash-language-server
            shellcheck
            shfmt
            # Containers
            dockerfile-language-server-nodejs
            docker-compose-language-service
          ];
          languages = {
            language = [
              {
                name = "nix";
                auto-format = true;
                formatter = { command = "nixfmt"; };
              }
              {
                name = "julia";
                auto-format = true;
              }
            ];
          };
          settings = {
            theme = "catppuccin_mocha_transparent";
            editor = {
              scrolloff = 5;
              line-number = "relative";
              cursorline = false;
              mouse = true;
              true-color = true;
              color-modes = true;
              bufferline = "multiple";
              auto-format = true;
              auto-save = false;
              middle-click-paste = true;
              cursor-shape = {
                normal = "block";
                insert = "bar";
                select = "block";
              };
              file-picker = {
                hidden = false;
                follow-symlinks = true;
              };
              indent-guides = {
                render = true;
                character = "│";
                skip-levels = 1;
              };
              lsp = {
                display-messages = true;
                display-inlay-hints = true;
              };
              statusline = {
                left = [ "mode" "spinner" "file-name" "file-modification-indicator" ];
                center = [ ];
                right = [ "diagnostics" "selections" "position" "file-type" ];
                separator = " │ ";
                mode.normal = "NORMAL";
                mode.insert = "INSERT";
                mode.select = "SELECT";
              };
            };
            keys.insert = {
              esc = [ "normal_mode" "move_char_left" ];
            };
            keys.normal = {
              esc = [ "collapse_selection" "keep_primary_selection" ];
              y = [ ":clipboard-yank" "yank" ];
              p = ":clipboard-paste-after";
              P = ":clipboard-paste-before";
              Y = [ ":clipboard-yank-join" "yank_main_selection_to_clipboard" ];
              R = ":clipboard-paste-replace";
            };
            keys.select = {
              esc = [ "collapse_selection" "keep_primary_selection" "normal_mode" ];
              y = [ ":clipboard-yank" "yank" ];
              p = ":clipboard-paste-after";
              P = ":clipboard-paste-before";
              Y = [ ":clipboard-yank-join" "yank_main_selection_to_clipboard" ];
              R = ":clipboard-paste-replace";
            };
          };
          themes = {
            catppuccin_mocha_transparent = {
              inherits = "catppuccin_mocha";
              "ui.background" = { };
              "ui.cursor" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.normal" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.insert" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.select" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.primary" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.primary.normal" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.primary.insert" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.primary.select" = { fg = "crust"; bg = "rosewater"; };
              "ui.cursor.match" = { fg = "crust"; bg = "peach"; };
              "ui.cursorline.primary" = { };
              "ui.cursorline.secondary" = { };
              "ui.statusline" = { fg = "subtext1"; };
              "ui.statusline.inactive" = { fg = "overlay0"; };
              "ui.statusline.normal" = { fg = "base"; bg = "lavender"; modifiers = [ "bold" ]; };
              "ui.statusline.insert" = { fg = "base"; bg = "green"; modifiers = [ "bold" ]; };
              "ui.statusline.select" = { fg = "base"; bg = "peach"; modifiers = [ "bold" ]; };
              "ui.bufferline" = { fg = "subtext0"; };
              "ui.bufferline.active" = { fg = "mauve"; underline = { color = "mauve"; style = "line"; }; modifiers = [ "bold" ]; };
            };
          };
        };
      };
    };
}
