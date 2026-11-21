{
  nixos.base =
    { pkgs, ... }:
    {
      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = [
          pkgs.xdg-desktop-portal
          pkgs.xdg-desktop-portal-gtk
        ];
        config = {
          common.default = [ "gtk" ];
          umbriel."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      };
    };
}
