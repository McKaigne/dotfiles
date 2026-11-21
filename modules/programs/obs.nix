{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.obs =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ flakeConfig.flake.modules.homeManager.obs ];
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vaapi
          obs-vkcapture
        ];
      };
    };

  flake.modules.homeManager.obs =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      obsTemplate = pkgs.writeText "obs-noctalia.qss.in" ''
        OBSTheme {
          window: {{colors.surface.default.hex}};
          windowText: {{colors.on_surface.default.hex}};
          base: {{colors.surface_container_low.default.hex}};
          alternateBase: {{colors.surface_container_lowest.default.hex}};
          text: {{colors.on_surface.default.hex}};
          button: {{colors.surface_container_high.default.hex}};
          buttonText: {{colors.on_surface.default.hex}};
          brightText: {{colors.tertiary.default.hex}};
          highlight: {{colors.primary.default.hex}};
          highlightedText: {{colors.on_primary.default.hex}};
        }
        QWidget {
          background-color: {{colors.surface.default.hex}};
          color: {{colors.on_surface.default.hex}};
          selection-background-color: {{colors.primary.default.hex}};
          selection-color: {{colors.on_primary.default.hex}};
        }
        QDockWidget::title {
          background-color: {{colors.surface_container_low.default.hex}};
          padding: 4px;
        }
        QToolBar {
          background-color: {{colors.surface_container_low.default.hex}};
          border: none;
        }
        QStatusBar {
          background-color: {{colors.surface_container_lowest.default.hex}};
          color: {{colors.on_surface_variant.default.hex}};
        }
        QPushButton {
          background-color: {{colors.surface_container_high.default.hex}};
          border: 1px solid {{colors.outline_variant.default.hex}};
          border-radius: 4px;
          padding: 4px 12px;
        }
        QPushButton:hover {
          background-color: {{colors.surface_container_highest.default.hex}};
        }
        QPushButton:pressed {
          background-color: {{colors.primary.default.hex}};
          color: {{colors.on_primary.default.hex}};
        }
        QLineEdit, QTextEdit, QPlainTextEdit {
          background-color: {{colors.surface_container_low.default.hex}};
          border: 1px solid {{colors.outline_variant.default.hex}};
          border-radius: 4px;
          color: {{colors.on_surface.default.hex}};
        }
        QScrollBar:vertical {
          background: {{colors.surface_container_low.default.hex}};
          width: 8px;
        }
        QScrollBar::handle:vertical {
          background: {{colors.outline_variant.default.hex}};
          border-radius: 4px;
        }
      '';
    in
    {
      xdg.configFile."noctalia/obs.toml".source =
        (pkgs.formats.toml { }).generate "obs-template.toml"
          {
            theme.templates.user.obs = {
              input_path = obsTemplate;
              output_path = "$XDG_CONFIG_HOME/obs-studio/themes/Noctalia.qss";
            };
          };

      home.activation.obsDefaultTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ini=${lib.escapeShellArg "${config.xdg.configHome}/obs-studio/global.ini"}
        if [ ! -e "$ini" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
          ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$ini")"
          printf '[Appearance]\nTheme=Noctalia\n' > "$ini"
        fi
      '';
    };
}
