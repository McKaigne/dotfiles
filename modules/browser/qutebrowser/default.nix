{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.qutebrowser ];

  home-manager.users.${user} = {
    xdg.configFile."qutebrowser/config.py" = {
      source = ./config.py;
      force = true;
    };
  };
}
