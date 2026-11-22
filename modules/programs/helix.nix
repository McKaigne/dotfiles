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
      # Language servers and formatters are on PATH (development/languages.nix).
      extraPackages = [pkgs.wl-clipboard];
      languages = {
        # Godot's editor serves GDScript completion while it is open.
        language-server.godot = {
          command = lib.getExe' pkgs.netcat "nc";
          args = ["127.0.0.1" "6005"];
        };
        language-server.vtsls = {
          command = "vtsls";
          args = ["--stdio"];
        };
        language-server.htmx-lsp.command = "htmx-lsp";
        language-server.sqls.command = "sqls";
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
          {
            name = "python";
            language-servers = ["basedpyright" "ruff"];
          }
          {
            name = "typescript";
            language-servers = ["vtsls"];
          }
          {
            name = "tsx";
            language-servers = ["vtsls"];
          }
          {
            name = "javascript";
            language-servers = ["vtsls"];
          }
          {
            # htmx attributes (hx-*) alongside the usual HTML servers.
            name = "html";
            language-servers = ["vscode-html-language-server" "superhtml" "htmx-lsp"];
          }
          {
            name = "sql";
            language-servers = ["sqls"];
          }
          {
            name = "gdscript";
            language-servers = ["godot"];
          }
          {
            # Subject at 50 columns, body at 72.
            name = "git-commit";
            rulers = [51 73];
            text-width = 72;
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
