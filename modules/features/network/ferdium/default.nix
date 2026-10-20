{ self, inputs, ... }: {
  flake.nixosModules.ferdium =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.ferdium ];

      home-manager.users.${user} = {
        xdg.configFile."Ferdium/config/custom.css" = {
          text = ''
            .titlebar,
            #titlebar,
            .window-controls,
            .window-controls-container,
            .top-bar,
            [class*="titlebar"],
            [class*="window-controls"],
            [class*="Titlebar"],
            [class*="WindowControls"] {
              display: none !important;
              height: 0 !important;
              visibility: hidden !important;
            }
          '';
          force = true;
        };

        xdg.configFile."Ferdium/custom.css" = {
          text = ''
            .titlebar,
            #titlebar,
            .window-controls,
            .window-controls-container,
            .top-bar,
            [class*="titlebar"],
            [class*="window-controls"],
            [class*="Titlebar"],
            [class*="WindowControls"] {
              display: none !important;
              height: 0 !important;
              visibility: hidden !important;
            }
          '';
          force = true;
        };
      };
    };
}
