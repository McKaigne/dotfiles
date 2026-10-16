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
            @define-color accent_color #cba6f7;
            @define-color accent_bg_color #cba6f7;
            @define-color accent_fg_color #11111b;

            @define-color destructive_bg_color #f38ba8;
            @define-color destructive_fg_color #11111b;

            @define-color error_bg_color #f38ba8;
            @define-color error_fg_color #11111b;

            @define-color window_bg_color #1e1e2e;
            @define-color window_fg_color #cdd6f4;

            @define-color view_bg_color #1e1e2e;
            @define-color view_fg_color #cdd6f4;

            @define-color headerbar_bg_color #1e1e2e;
            @define-color headerbar_fg_color #cdd6f4;
            @define-color headerbar_backdrop_color @window_bg_color;

            @define-color popover_bg_color #313244;
            @define-color popover_fg_color #cdd6f4;

            @define-color card_bg_color #313244;
            @define-color card_fg_color #cdd6f4;

            @define-color dialog_bg_color #1e1e2e;
            @define-color dialog_fg_color #cdd6f4;

            @define-color sidebar_bg_color #181825;
            @define-color sidebar_fg_color #cdd6f4;

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
            @define-color accent_color #cba6f7;
            @define-color accent_bg_color #cba6f7;
            @define-color accent_fg_color #11111b;

            @define-color destructive_bg_color #f38ba8;
            @define-color destructive_fg_color #11111b;

            @define-color error_bg_color #f38ba8;
            @define-color error_fg_color #11111b;

            @define-color window_bg_color #1e1e2e;
            @define-color window_fg_color #cdd6f4;

            @define-color view_bg_color #1e1e2e;
            @define-color view_fg_color #cdd6f4;

            @define-color headerbar_bg_color #1e1e2e;
            @define-color headerbar_fg_color #cdd6f4;

            @define-color popover_bg_color #313244;
            @define-color popover_fg_color #cdd6f4;

            @define-color card_bg_color #313244;
            @define-color card_fg_color #cdd6f4;

            @define-color dialog_bg_color #1e1e2e;
            @define-color dialog_fg_color #cdd6f4;

            @define-color sidebar_bg_color #181825;
            @define-color sidebar_fg_color #cdd6f4;

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
            active_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
            disabled_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
            inactive_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
          '';
          force = true;
        };

        xdg.configFile."qt5ct/colors/catppuccin.conf" = {
          text = ''
            [ColorScheme]
            active_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
            disabled_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
            inactive_colors=#cdd6f4, #1e1e2e, #ffffff, #cacaca, #9f9f9f, #b8b8b8, #cdd6f4, #ffffff, #cdd6f4, #1e1e2e, #1e1e2e, #11111b, #6d10da, #e4d0fb, #fab387, #cba6f7, #313244, #1e1e2e, #313244, #cdd6f4, #cdd6f4, #cba6f7
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
