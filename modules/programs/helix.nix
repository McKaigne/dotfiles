{
  flake.modules.homeManager.helix = {
    config,
    lib,
    pkgs,
    ...
  }: let
    themeFile = "${config.xdg.configHome}/helix/themes/noctalia.toml";
  in {
    programs.helix = {
      enable = true;
      defaultEditor = false;
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
              + "${config.workstation.hostname}.options";
          };
        };
        language = [
          {
            name = "nix";
            auto-format = true;
            formatter.command = "nixfmt";
            language-servers = ["nixd"];
          }
          {
            name = "julia";
            auto-format = true;
          }
        ];
      };
      settings = {
        theme = "noctalia";
        editor = {
          scrolloff = 5;
          line-number = "relative";
          cursorline = false;
          mouse = true;
          true-color = true;
          color-modes = true;
          bufferline = "multiple";
          auto-format = true;
          auto-save.focus-lost = true;
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
            center = [];
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
    };

    home.activation.seedHelixTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      themeFile=${lib.escapeShellArg themeFile}
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$themeFile")"
      if [ ! -f "$themeFile" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
        printf '"ui.background" = "none"\n' > "$themeFile"
      fi
    '';
  };
}
