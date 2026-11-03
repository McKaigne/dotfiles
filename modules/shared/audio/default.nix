_: {
  flake.nixosModules.audio =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      hardware.firmware = with pkgs; [
        sof-firmware
        alsa-firmware
      ];

      home-manager.users.${user} = {
        services.easyeffects.enable = true;

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

        xdg.configFile."kdeglobals" = {
          text = ''
            [General]
            ColorScheme=CatppuccinMocha
            Name=Catppuccin Mocha

            [Colors:Window]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=24,24,37

            [Colors:View]
            BackgroundNormal=30,30,46
            ForegroundNormal=205,214,244
            BackgroundAlternate=49,50,68

            [Colors:Button]
            BackgroundNormal=49,50,68
            ForegroundNormal=205,214,244

            [Colors:Selection]
            BackgroundNormal=203,166,247
            ForegroundNormal=17,17,27
          '';
          force = false;
        };
      };

      environment.systemPackages = with pkgs; [
        easyeffects
        pavucontrol
        cava
      ];
    };
}
