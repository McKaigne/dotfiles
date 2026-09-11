{ self, ... }:
let
  themeModule = { config, pkgs, lib, ... }:
    let
      cfg = config.cursor;
    in
    {
      options.cursor = {
        theme = lib.mkOption {
          type = lib.types.str;
          default = "Bibata-Modern-Classic";
          description = "System-wide cursor theme name";
        };
        size = lib.mkOption {
          type = lib.types.int;
          default = 16;
          description = "System-wide cursor size";
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-fixed;
          description = "Cursor package derivation";
        };
      };

      config = {
        environment.systemPackages = [ cfg.package pkgs.adw-gtk3 ];

        environment.sessionVariables = {
          XCURSOR_THEME    = cfg.theme;
          XCURSOR_SIZE     = toString cfg.size;
          HYPRCURSOR_THEME = cfg.theme;
          HYPRCURSOR_SIZE  = toString cfg.size;
          XCURSOR_PATH     = lib.mkForce "${cfg.package}/share/icons:/run/current-system/sw/share/icons";
          NIXOS_OZONE_WL   = "1";
        };

        environment.etc."xdg/icons/default/index.theme".text = ''
          [Icon Theme]
          Name=Default
          Comment=Default Cursor Theme
          Inherits=${cfg.theme}
        '';

        # Live Noctalia CSS Bridge for GTK 3 & 4
        environment.etc."xdg/gtk-3.0/gtk.css".text = ''
          @import url("file:///home/${config.mainUser}/.config/gtk-3.0/noctalia.css");
        '';
        environment.etc."xdg/gtk-4.0/gtk.css".text = ''
          @import url("file:///home/${config.mainUser}/.config/gtk-4.0/noctalia.css");
        '';

        programs.dconf = {
          enable = true;
          profiles.user.databases = [{
            settings = {
              "org/gnome/desktop/interface" = {
                cursor-theme = cfg.theme;
                cursor-size  = lib.gvariant.mkInt32 cfg.size;
                icon-theme   = "Adwaita";
                gtk-theme    = "adw-gtk3-dark";
                color-scheme = "prefer-dark";
              };
            };
          }];
        };
      };
    };
in
{
  flake.nixosModules.theme = themeModule;
  flake.nixosModules.cursor = themeModule;

  perSystem = { pkgs, ... }:
    let
      bibataFixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
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
      packages.bibata-cursors-fixed = bibataFixed;
    };
}