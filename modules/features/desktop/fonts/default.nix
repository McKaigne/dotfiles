{ self, inputs, ... }: {
  flake.nixosModules.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          cozette
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-color-emoji
        ];
        fontconfig = {
          enable = true;
          allowBitmaps = true;
          useEmbeddedBitmaps = true;
          antialias = true;
          hinting = {
            enable = true;
            style = "slight";
          };
          defaultFonts = {
            monospace = [ "Cozette" ];
            sansSerif = [ "Cozette" "Noto Sans" ];
            serif = [ "Noto Serif" ];
            emoji = [ "Noto Color Emoji" ];
          };
          localConf = ''
            <?xml version="1.0"?>
            <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
            <fontconfig>
              <match target="font">
                <test name="family" qual="any">
                  <string>Cozette</string>
                </test>
                <edit name="antialias" mode="assign">
                  <bool>false</bool>
                </edit>
                <edit name="hinting" mode="assign">
                  <bool>false</bool>
                </edit>
                <edit name="autohint" mode="assign">
                  <bool>false</bool>
                </edit>
              </match>
            </fontconfig>
          '';
        };
      };
    };
}
