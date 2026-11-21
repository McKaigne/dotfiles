{
  flake.modules.homeManager."desktop-umbriel" =
    { lib, pkgs, ... }:
    let
      noctalia = lib.getExe pkgs.noctalia;
    in
    {
      programs.umbriel.settings.general.autostart = [
        noctalia
      ];
    };
}
