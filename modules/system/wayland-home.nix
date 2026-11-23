{
  homeManager.base = {pkgs, ...}: {
    home.sessionVariables = {
      # Native Wayland where the app supports it, matching NIXOS_OZONE_WL
      # (environment.nix); x11 here sent unwrapped Electron apps to XWayland.
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
      QT_QPA_PLATFORM = "wayland";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    };

    home.packages = [pkgs.libnotify pkgs.wl-clipboard];
  };
}
