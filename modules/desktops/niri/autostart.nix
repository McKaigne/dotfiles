{
  flake.modules.homeManager.desktop-niri =
    { lib, pkgs, ... }:
    let
      noctalia = lib.getExe pkgs.noctalia;
      systemctl = "${pkgs.systemd}/bin/systemctl";
    in
    {
      programs.niri.settings.spawn-at-startup = [
        {
          command = [
            systemctl
            "--user"
            "import-environment"
            "PATH"
            "XDG_DATA_DIRS"
            "WAYLAND_DISPLAY"
            "XDG_CURRENT_DESKTOP"
            "SHELL"
            "QT_QPA_PLATFORM"
            "QT_QPA_PLATFORMTHEME"
            "XCURSOR_THEME"
            "XCURSOR_SIZE"
          ];
        }
        { command = [ noctalia ]; }
      ];
    };
}
