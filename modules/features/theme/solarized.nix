{ self, inputs, ... }: {
  flake.nixosModules.solarizedTheme = { config, pkgs, lib, ... }:
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
        gtk4.theme = null;
      };

      dconf.settings."org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        gtk-theme = "adw-gtk3-dark";
        icon-theme = "WhiteSur";
      };

      xdg.configFile."gtk-3.0/gtk.css".text = "@import 'noctalia.css';\n";
      xdg.configFile."gtk-4.0/gtk.css".text = "@import 'noctalia.css';\n";

      # Pure Qt configuration pointing to Noctalia generated palettes
      xdg.configFile."qt6ct/qt6ct.conf".text = ''
        [Appearance]
        color_scheme_path=/home/${user}/.config/qt6ct/colors/noctalia.conf
        custom_palette=true
        icon_theme=WhiteSur
        standard_dialogs=default
        style=Adwaita-Dark
      '';

      xdg.configFile."qt5ct/qt5ct.conf".text = ''
        [Appearance]
        color_scheme_path=/home/${user}/.config/qt5ct/colors/noctalia.conf
        custom_palette=true
        icon_theme=WhiteSur
        standard_dialogs=default
        style=Adwaita-Dark
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
    ];
  };
}
