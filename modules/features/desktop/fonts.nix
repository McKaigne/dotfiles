{ self, inputs, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.lilex
        ibm-plex
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
          monospace = [ "Lilex Nerd Font" "IBM Plex Mono" ];
          sansSerif = [ "IBM Plex Sans" "Noto Sans" ];
          serif = [ "IBM Plex Serif" "Noto Serif" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}
