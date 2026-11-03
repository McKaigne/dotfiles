_: {
  flake.nixosModules.onlyoffice =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];

      home-manager.users.${user} = {
        xdg.configFile."onlyoffice/DesktopEditors.conf" = {
          text = ''
            [General]
            UITheme=theme-dark
          '';
          force = false;
        };
      };
    };
}
