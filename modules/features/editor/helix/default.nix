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
            shellcheck
            shfmt
            dockerfile-language-server
            docker-compose-language-service
          ];
          languages = {
            language-server.nixd = {
              command = "nixd";
              config.nixd = {
                nixpkgs.expr = "import <nixpkgs> { }";
                options.nixos.expr =
                  "(builtins.getFlake \"/etc/nixos\").nixosConfigurations."
                  + "${config.networking.hostName}.options";
              };
            };
            language = [
              {
                name = "nix";
                auto-format = true;
                formatter = {
                  command = "nixfmt";
                };
                language-servers = [ "nixd" ];
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
              auto-save = {
                focus-lost = true;
              };
              end-of-line-diagnostics = "hint";
              inline-diagnostics = {
                cursor-line = "warning";
                other-lines = "disable";
              };
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
                snippets = true;
              };
              statusline = {
                left = [
                  "mode"
                  "file-name"
                  "file-modification-indicator"
                ];
                center = [ ];
                right = [
                  "diagnostics"
                  "selections"
                  "position"
                  "file-type"
                  "spinner"
                ];
                separator = " │ ";
                mode.normal = "NOR";
                mode.insert = "INS";
                mode.select = "SEL";
              };
            };
          };
          themes = {
            catppuccin_mocha_transparent = {
              inherits = "catppuccin_mocha";
              "ui.background" = { };
              "ui.cursor" = {
                fg = "crust";
                bg = "rosewater";
              };
              "ui.cursor.primary" = {
                fg = "crust";
                bg = "rosewater";
              };
              "ui.cursor.match" = {
                fg = "crust";
                bg = "peach";
              };
              "ui.cursorline.primary" = { };
              "ui.cursorline.secondary" = { };
              "ui.statusline" = {
                fg = "subtext1";
              };
              "ui.statusline.inactive" = {
                fg = "overlay0";
              };
              "ui.statusline.normal" = {
                fg = "base";
                bg = "mauve";
                modifiers = [ "bold" ];
              };
              "ui.statusline.insert" = {
                fg = "base";
                bg = "green";
                modifiers = [ "bold" ];
              };
              "ui.statusline.select" = {
                fg = "base";
                bg = "peach";
                modifiers = [ "bold" ];
              };
              "ui.statusline.separator" = {
                fg = "surface2";
              };
              "ui.bufferline" = {
                fg = "subtext0";
              };
              "ui.bufferline.active" = {
                fg = "mauve";
                underline = {
                  color = "mauve";
                  style = "line";
                };
                modifiers = [ "bold" ];
              };
            };
          };
        };
      };
    };
}
