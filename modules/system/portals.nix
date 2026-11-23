{
  nixos.base = {pkgs, ...}: {
    xdg.portal = {
      enable = true;
      config.common.default = "gtk";
      xdgOpenUsePortal = true;
      extraPortals = [pkgs.xdg-desktop-portal-gtk];
    };
  };
}
