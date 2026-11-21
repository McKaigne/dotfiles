{
  flake.modules.homeManager."desktop-niri" = {
    pkgs,
    lib,
    ...
  }: let
    noctalia = lib.getExe pkgs.noctalia;
  in {
    programs.niri.settings.spawn-at-startup = [
      {command = [noctalia];}
    ];
  };
}
