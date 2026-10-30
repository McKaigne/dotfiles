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
            nixd
            nixfmt
            marksman
            taplo
            yaml-language-server
            bash-language-server
            shfmt
            pyright
            ruff
            rust-analyzer
            rustfmt
            clang-tools
          ];
          settings = {
            theme = "catppuccin_mocha_transparent";
            editor = {
              scrolloff = 5;
              line-number = "relative";
              cursorline = true;
              mouse = true;
              true-color = true;
              color-modes = true;
              bufferline = "multiple";
              auto-format = true;
              auto-save = false;
              middle-click-paste = true;
              cursor-shape = {
                insert = "bar";
                normal = "block";
                select = "underline";
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
            keys.normal = {
              y = [ ":clipboard-yank" "yank" ];
              p = ":clipboard-paste-after";
              P = ":clipboard-paste-before";
              Y = [ ":clipboard-yank-join" "yank_main_selection_to_clipboard" ];
              R = ":clipboard-paste-replace";
            };
            keys.select = {
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
              "ui.cursorline.primary" = { bg = "surface0"; };
              "ui.cursorline.secondary" = { bg = "surface0"; };
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
