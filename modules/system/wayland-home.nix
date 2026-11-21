{
  homeManager.base =
    { pkgs, ... }:
    {
      home.sessionVariables = {
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        QT_QPA_PLATFORM = "wayland";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      home.packages = [
        pkgs.libnotify
        pkgs.wl-clipboard
      ];
    };
}
