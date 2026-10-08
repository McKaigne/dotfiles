{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.zathura ];

  home-manager.users.${user} = {
    xdg.configFile."zathura/zathurarc".text = ''
      include noctaliarc
      set selection-clipboard clipboard
      set window-title-basename true
    '';
  };
}
