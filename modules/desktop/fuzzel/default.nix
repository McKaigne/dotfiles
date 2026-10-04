{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.fuzzel ];

  home-manager.users.${user} = {
    xdg.configFile."fuzzel/fuzzel.ini" = {
      source = ./fuzzel.ini;
      force = true;
    };
  };
}
