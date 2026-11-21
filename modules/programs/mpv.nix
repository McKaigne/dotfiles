{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.mpv =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ flakeConfig.flake.modules.homeManager.mpv ];
      environment.systemPackages = [ pkgs.mpv ];
    };

  flake.modules.homeManager.mpv = {
    xdg.configFile."mpv/mpv.conf" = {
      text = ''
        vo=gpu-next
        gpu-context=wayland
        hwdec=auto-safe
      '';
      force = true;
    };
  };
}
