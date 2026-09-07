{ self, inputs, ... }: {
  flake.nixosModules.cursor = { pkgs, lib, ... }:
    let
      cursorTheme = "Bibata-Modern-Classic";
      cursorSize  = 16;

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

      # Unified cursor environment variables (single source of truth)
      environment.sessionVariables = {
        XCURSOR_THEME  = cursorTheme;
        XCURSOR_SIZE   = toString cursorSize;
        HYPRCURSOR_THEME = cursorTheme;
        HYPRCURSOR_SIZE  = toString cursorSize;
        XCURSOR_PATH   = lib.mkForce "${bibataFixed}/share/icons:/run/current-system/sw/share/icons";
        NIXOS_OZONE_WL = "1";
      };

      # System-wide X11/Wayland cursor fallback
      environment.etc."xdg/icons/default/index.theme".text = ''
        [Icon Theme]
        Name=Default
        Comment=Default Cursor Theme
        Inherits=${cursorTheme}
      '';

      # Declarative dconf/GSettings for GTK/GNOME cursor discovery
      programs.dconf = {
        enable = true;
        profiles.user.databases = [{
          settings = {
            "org/gnome/desktop/interface" = {
              cursor-theme = cursorTheme;
              cursor-size  = lib.gvariant.mkInt32 cursorSize;
            };
          };
        }];
      };
    };
}

