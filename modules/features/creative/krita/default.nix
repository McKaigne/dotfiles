_: {
  flake.nixosModules.krita =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.krita ];

      home-manager.users.${user} = {
        xdg.dataFile."color-schemes/CatppuccinMocha.colors" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha

            [Colors:Window]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=24,24,37
            ForegroundInactive=108,112,134

            [Colors:View]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=49,50,68
            ForegroundInactive=108,112,134

            [Colors:Button]
            BackgroundNormal=49,50,68
            ForegroundNormal=205,214,244
            BackgroundAlternate=69,71,90

            [Colors:Selection]
            BackgroundNormal=203,166,247
            ForegroundNormal=17,17,27

            [Colors:Tooltip]
            BackgroundNormal=24,24,37
            ForegroundNormal=205,214,244
          '';
          force = true;
        };

        xdg.dataFile."krita/color-schemes/CatppuccinMocha.colors" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha

            [Colors:Window]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=24,24,37
            ForegroundInactive=108,112,134

            [Colors:View]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=49,50,68
            ForegroundInactive=108,112,134

            [Colors:Button]
            BackgroundNormal=49,50,68
            ForegroundNormal=205,214,244
            BackgroundAlternate=69,71,90

            [Colors:Selection]
            BackgroundNormal=203,166,247
            ForegroundNormal=17,17,27

            [Colors:Tooltip]
            BackgroundNormal=24,24,37
            ForegroundNormal=205,214,244
          '';
          force = true;
        };

        xdg.configFile."kritarc" = {
          text = ''
            [General]
            colorScheme=CatppuccinMocha
          '';
          force = false;
        };
      };
    };
}
