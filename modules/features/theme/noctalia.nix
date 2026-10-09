{ self, inputs, ... }: {
  flake.nixosModules.noctaliaTheme = { config, pkgs, lib, ... }:
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
          name = "WhiteSur";
          package = pkgs.whitesur-icon-theme;
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
        icon-theme = "WhiteSur";
        font-name = "IBM Plex Sans 11";
      };

      xdg.configFile."gtk-3.0/gtk.css".text = ''
        @import 'noctalia.css';

        /* Eradicate window controls and close buttons */
        headerbar windowcontrols,
        headerbar button.close,
        tab button.close,
        button.close {
          display: none;
          margin: 0;
          padding: 0;
        }

        /* Modern flat styling for PCManFM */
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

      xdg.configFile."gtk-4.0/gtk.css".text = ''
        @import 'noctalia.css';

        headerbar windowcontrols,
        headerbar button.close,
        tab button.close,
        button.close {
          display: none;
          margin: 0;
          padding: 0;
        }
      '';

      xdg.configFile."qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=/home/${user}/.config/qt6ct/colors/noctalia.conf
        custom_palette=true
        icon_theme=WhiteSur
        standard_dialogs=default
        style=Adwaita-Dark

        [Fonts]
        fixed="Lilex Nerd Font,11,-1,5,50,0,0,0,0,0"
        general="IBM Plex Sans,11,-1,5,50,0,0,0,0,0"
      '';

      xdg.configFile."qt5ct/qt5ct.conf".text = ''
        [Appearance]
        color_scheme_path=/home/${user}/.config/qt5ct/colors/noctalia.conf
        custom_palette=true
        icon_theme=WhiteSur
        standard_dialogs=default
        style=Adwaita-Dark

        [Fonts]
        fixed="Lilex Nerd Font,11,-1,5,50,0,0,0,0,0"
        general="IBM Plex Sans,11,-1,5,50,0,0,0,0,0"
      '';
    };

    qt = {
      enable = true;
      style = "adwaita-dark";
    };

    environment.sessionVariables = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "16";
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt6ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    environment.systemPackages = with pkgs; [
      adw-gtk3
      whitesur-icon-theme
      bibataCursorsFixed
      libsForQt5.qt5ct
      kdePackages.qt6ct
      ibm-plex
    ];
  };
}
