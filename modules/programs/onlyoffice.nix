{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.onlyoffice =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [
        flakeConfig.flake.modules.homeManager.onlyoffice
      ];
      environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];
    };

  flake.modules.homeManager.onlyoffice = {
    xdg.configFile."onlyoffice/DesktopEditors.conf" = {
      text = ''
        [General]
        UITheme=theme-dark
      '';
      force = false;
    };
  };
}
