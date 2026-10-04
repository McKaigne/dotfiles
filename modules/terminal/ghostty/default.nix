{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.ghostty ];

  home-manager.users.${user} = {
    xdg.configFile."ghostty/config".source = ./config;
  };
}
