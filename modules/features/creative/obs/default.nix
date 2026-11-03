_: {
  flake.nixosModules.obs =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      programs.obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          obs-vaapi
          obs-vkcapture
        ];
      };

      home-manager.users.${user} = {
        xdg.configFile."obs-studio/themes/Catppuccin_Mocha.qss" = {
          text = ''
            OBSTheme {
              window: ${p.base};
              windowText: ${p.text};
              base: ${p.mantle};
              alternateBase: ${p.crust};
              text: ${p.text};
              button: ${p.surface0};
              buttonText: ${p.text};
              brightText: ${p.rosewater};
              highlight: ${p.mauve};
              highlightedText: ${p.crust};
            }
            QWidget {
              background-color: ${p.base};
              color: ${p.text};
              selection-background-color: ${p.mauve};
              selection-color: ${p.crust};
            }
            QDockWidget::title {
              background-color: ${p.mantle};
              padding: 4px;
            }
            QToolBar {
              background-color: ${p.mantle};
              border: none;
            }
            QStatusBar {
              background-color: ${p.crust};
              color: ${p.subtext0};
            }
            QPushButton {
              background-color: ${p.surface0};
              border: 1px solid ${p.surface1};
              border-radius: 4px;
              padding: 4px 12px;
            }
            QPushButton:hover {
              background-color: ${p.surface1};
            }
            QPushButton:pressed {
              background-color: ${p.mauve};
              color: ${p.crust};
            }
            QLineEdit, QTextEdit, QPlainTextEdit {
              background-color: ${p.mantle};
              border: 1px solid ${p.surface1};
              border-radius: 4px;
              color: ${p.text};
            }
            QScrollBar:vertical {
              background: ${p.mantle};
              width: 8px;
            }
            QScrollBar::handle:vertical {
              background: ${p.surface1};
              border-radius: 4px;
            }
          '';
          force = true;
        };

        xdg.configFile."obs-studio/global.ini" = {
          text = ''
            [Appearance]
            Theme=Catppuccin_Mocha
          '';
          force = false;
        };
      };
    };
}
