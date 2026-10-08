{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.mpv ];

  home-manager.users.${user} = {
    xdg.configFile."mpv/mpv.conf".text = ''
      vo=gpu-next
      gpu-context=wayland
      hwdec=auto-safe
    '';
  };
}
