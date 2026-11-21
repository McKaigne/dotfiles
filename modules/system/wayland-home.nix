{
  homeManager.base = {pkgs, ...}: {
    home.sessionVariables = {
      ELECTRON_OZONE_PLATFORM_HINT = "x11";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    home.packages = [pkgs.libnotify pkgs.wl-clipboard];
  };
}
