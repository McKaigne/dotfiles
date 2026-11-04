_: {
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          atkinson-hyperlegible
          nerd-fonts.atkynson-mono
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
        fontconfig = {
          enable = true;
          antialias = true;
          hinting = {
            enable = true;
            style = "slight";
          };
          subpixel = {
            rgba = "rgb";
            lcdfilter = "default";
          };
          defaultFonts = {
            monospace = [ "AtkynsonMono Nerd Font" ];
            sansSerif = [
              "Atkinson Hyperlegible"
              "Noto Sans"
            ];
            serif = [ "Noto Serif" ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
}
