_: {
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
              <!-- Reject vector fallback so applications never load blurry TTF -->
              <selectfont>
                <acceptfont>
                  <pattern>
                    <patelt name="family"><string>Cozette</string></patelt>
                  </pattern>
                </acceptfont>
                <rejectfont>
                  <pattern>
                    <patelt name="family"><string>CozetteVector</string></patelt>
                  </pattern>
                </rejectfont>
              </selectfont>

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
                <edit name="embeddedbitmap" mode="assign">
                  <bool>true</bool>
                </edit>
                <edit name="rgba" mode="assign">
                  <const>none</const>
                </edit>
              </match>
            </fontconfig>
          '';
        };
      };
    };
}
