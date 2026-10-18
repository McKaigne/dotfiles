{ self, inputs, ... }: {
  flake.nixosModules.catppuccinTheme =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      p = config.palette;

      bibataCursorsFixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
        mkdir -p $out/share/icons
        cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic $out/share/icons/Bibata-Modern-Classic
        chmod -R u+w $out/share/icons/Bibata-Modern-Classic
        cd $out/share/icons/Bibata-Modern-Classic/cursors
        [ -e hand2 ] || ln -sf pointer hand2
        [ -e sb_v_double_arrow ] || ln -sf ns-resize sb_v_double_arrow
        [ -e sb_h_double_arrow ] || ln -sf ew-resize sb_h_double_arrow
      '';
    in
    {
      home-manager.users.${user} = {
        gtk = {
          enable = true;
          theme = {
            name = "adw-gtk3-dark";
            package = pkgs.adw-gtk3;
          };
          iconTheme = {
            name = "Papirus-Dark";
            package = pkgs.papirus-icon-theme;
          };
          font = {
            name = "IBM Plex Sans";
            size = 11;
            package = pkgs.ibm-plex;
          };
          gtk4.theme = null;
        };

        dconf.settings."org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
          gtk-theme = "adw-gtk3-dark";
          icon-theme = "Papirus-Dark";
          font-name = "IBM Plex Sans 11";
        };

        xdg.configFile."gtk-3.0/gtk.css" = {
          text = ''
            @define-color accent_color ${p.mauve};
            @define-color accent_bg_color ${p.mauve};
            @define-color accent_fg_color ${p.crust};

            @define-color destructive_bg_color ${p.red};
            @define-color destructive_fg_color ${p.crust};

            @define-color error_bg_color ${p.red};
            @define-color error_fg_color ${p.crust};

            @define-color window_bg_color ${p.base};
            @define-color window_fg_color ${p.text};

            @define-color view_bg_color ${p.base};
            @define-color view_fg_color ${p.text};

            @define-color headerbar_bg_color ${p.base};
            @define-color headerbar_fg_color ${p.text};
            @define-color headerbar_backdrop_color @window_bg_color;

            @define-color popover_bg_color ${p.surface0};
            @define-color popover_fg_color ${p.text};

            @define-color card_bg_color ${p.surface0};
            @define-color card_fg_color ${p.text};

            @define-color dialog_bg_color ${p.base};
            @define-color dialog_fg_color ${p.text};

            @define-color sidebar_bg_color ${p.mantle};
            @define-color sidebar_fg_color ${p.text};

            headerbar windowcontrols,
            headerbar button.close,
            tab button.close,
            button.close {
              display: none;
              margin: 0;
              padding: 0;
            }

            .pcmanfm-sidebar,
            pcmanfm frame,
            pcmanfm treeview {
              border: none;
              box-shadow: none;
            }

            pcmanfm treeview {
              padding: 2px 4px;
            }
          '';
          force = true;
        };

        xdg.configFile."gtk-4.0/gtk.css" = {
          text = ''
            @define-color accent_color ${p.mauve};
            @define-color accent_bg_color ${p.mauve};
            @define-color accent_fg_color ${p.crust};

            @define-color destructive_bg_color ${p.red};
            @define-color destructive_fg_color ${p.crust};

            @define-color error_bg_color ${p.red};
            @define-color error_fg_color ${p.crust};

            @define-color window_bg_color ${p.base};
            @define-color window_fg_color ${p.text};

            @define-color view_bg_color ${p.base};
            @define-color view_fg_color ${p.text};

            @define-color headerbar_bg_color ${p.base};
            @define-color headerbar_fg_color ${p.text};
            @define-color headerbar_backdrop_color @window_bg_color;

            @define-color popover_bg_color ${p.surface0};
            @define-color popover_fg_color ${p.text};

            @define-color card_bg_color ${p.surface0};
            @define-color card_fg_color ${p.text};

            @define-color dialog_bg_color ${p.base};
            @define-color dialog_fg_color ${p.text};

            @define-color sidebar_bg_color ${p.mantle};
            @define-color sidebar_fg_color ${p.text};

            headerbar windowcontrols,
            headerbar button.close,
            tab button.close,
            button.close {
              display: none;
              margin: 0;
              padding: 0;
            }
          '';
          force = true;
        };

        xdg.configFile."qt6ct/qt6ct.conf" = {
          text = ''
            [Appearance]
            color_scheme_path=/home/${user}/.config/qt6ct/colors/catppuccin.conf
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
            style=Adwaita-Dark

            [Fonts]
            fixed="Lilex Nerd Font,11,-1,5,50,0,0,0,0,0"
            general="IBM Plex Sans,11,-1,5,50,0,0,0,0,0"
          '';
          force = true;
        };

        xdg.configFile."qt5ct/qt5ct.conf" = {
          text = ''
            [Appearance]
            color_scheme_path=/home/${user}/.config/qt5ct/colors/catppuccin.conf
            custom_palette=true
            icon_theme=Papirus-Dark
            standard_dialogs=default
            style=Adwaita-Dark

            [Fonts]
            fixed="Lilex Nerd Font,11,-1,5,50,0,0,0,0,0"
            general="IBM Plex Sans,11,-1,5,50,0,0,0,0,0"
          '';
          force = true;
        };

        xdg.configFile."qt6ct/colors/catppuccin.conf" = {
          text = ''
            [ColorScheme]
            active_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
            disabled_colors=${p.overlay0}, ${p.mantle}, ${p.surface0}, ${p.mantle}, ${p.crust}, ${p.surface1}, ${p.overlay0}, ${p.rosewater}, ${p.overlay0}, ${p.base}, ${p.base}, ${p.crust}, ${p.surface1}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.overlay0}, ${p.surface1}, ${p.mauve}
            inactive_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
          '';
          force = true;
        };

        xdg.configFile."qt5ct/colors/catppuccin.conf" = {
          text = ''
            [ColorScheme]
            active_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
            disabled_colors=${p.overlay0}, ${p.mantle}, ${p.surface0}, ${p.mantle}, ${p.crust}, ${p.surface1}, ${p.overlay0}, ${p.rosewater}, ${p.overlay0}, ${p.base}, ${p.base}, ${p.crust}, ${p.surface1}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.overlay0}, ${p.surface1}, ${p.mauve}
            inactive_colors=${p.text}, ${p.surface0}, ${p.surface1}, ${p.surface0}, ${p.mantle}, ${p.surface2}, ${p.text}, ${p.rosewater}, ${p.text}, ${p.base}, ${p.base}, ${p.crust}, ${p.mauve}, ${p.crust}, ${p.blue}, ${p.lavender}, ${p.mantle}, ${p.base}, ${p.mantle}, ${p.text}, ${p.overlay0}, ${p.mauve}
          '';
          force = true;
        };
      };

      qt = {
        enable = true;
        platformTheme = "qt5ct";
        style = "adwaita-dark";
      };

      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "16";
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORM = "wayland";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      };

      environment.systemPackages = with pkgs; [
        adw-gtk3
        papirus-icon-theme
        bibataCursorsFixed
        ibm-plex
        kdePackages.qt6ct
      ];
    };
}
