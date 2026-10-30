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
              bufferline = "always";
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
                left = [ "mode" "spinner" "version-control" "file-name" "read-only-indicator" "file-modification-indicator" ];
                right = [ "diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type" ];
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
              "ui.statusline" = { fg = "text"; bg = "mantle"; };
            };
          };
        };
      };
    };
}
