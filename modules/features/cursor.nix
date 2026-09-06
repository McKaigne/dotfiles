{ self, inputs, ... }: {
  flake.nixosModules.cursor = { pkgs, lib, ... }:
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
      environment.systemPackages = [ bibataFixed ];

      # Unified cursor environment variables
      environment.sessionVariables = {
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "16";
        HYPRCURSOR_THEME = "Bibata-Modern-Classic";
        HYPRCURSOR_SIZE = "16";
        XCURSOR_PATH = "${bibataFixed}/share/icons:/run/current-system/sw/share/icons";
        NIXOS_OZONE_WL = "1";
      };

      # System-wide X11/Wayland cursor fallback configuration
      environment.etc."xdg/icons/default/index.theme".text = ''
        [Icon Theme]
        Name=Default
        Comment=Default Cursor Theme
        Inherits=Bibata-Modern-Classic
      '';

      # Declarative Dconf/GSettings for GNOME/GTK/Ozone cursor discovery
      programs.dconf = {
        enable = true;
        profiles.user.databases = [{
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = "Bibata-Modern-Classic";
              cursor-size = lib.gvariant.mkInt32 16;
            };
          };
        }];
      };
    };
}
