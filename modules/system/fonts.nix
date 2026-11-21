{
  nixos.base =
    { pkgs, ... }:
    {
      fonts = {
        packages = [
          pkgs.maple-mono.NF
          pkgs.noto-fonts
          pkgs.noto-fonts-cjk-sans
          pkgs.noto-fonts-color-emoji
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
            monospace = [ "Maple Mono NF" ];
            sansSerif = [
              "Maple Mono NF"
              "Noto Sans"
            ];
            serif = [
              "Maple Mono NF"
              "Noto Serif"
            ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
}
