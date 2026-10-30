{ self, inputs, ... }: {
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
              line-number = "relative";
              cursorline = true;
              mouse = true;
              true-color = true;
              color-modes = true;
              cursor-shape = {
                insert = "bar";
                normal = "block";
                select = "underline";
              };
              indent-guides = {
                render = true;
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
