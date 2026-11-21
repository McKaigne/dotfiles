{
  nixos.base =
    { lib, pkgs, ... }:
    let
      garamontoCodeSrc = pkgs.fetchFromGitHub {
        owner = "rizese";
        repo = "garamonto-code";
        rev = "2951f274e721eb5ae2e0e7c898effdf579f39c6e";
        hash = "sha256-8ZCwE/lvXZ1uPeYBAV7s2bZaaMuCRxM694pHcBEpRyA=";
      };

      garamontoNerdFont = pkgs.stdenvNoCC.mkDerivation {
        pname = "garamonto-code-nerd-font";
        version = "2951f274";
        src = garamontoCodeSrc;

        nativeBuildInputs = [ pkgs.nerd-font-patcher ];

        dontConfigure = true;

        buildPhase = ''
          runHook preBuild
          export HOME="$TMPDIR"
          install -dm0755 patched
          for ttf in fonts/ttf/GaramontoCode*.ttf; do
            nerd-font-patcher --complete --outputdir patched "$ttf"
          done
          runHook postBuild
        '';

        installPhase = ''
          runHook preInstall
          install -dm0755 "$out/share/fonts/truetype"
          cp -r patched/*.ttf "$out/share/fonts/truetype/"
          runHook postInstall
        '';

        meta = {
          description = "Garamonto Code patched with Nerd Font glyphs";
          license = lib.licenses.ofl;
          platforms = lib.platforms.all;
        };
      };
    in
    {
      fonts = {
        packages = [
          pkgs.eb-garamond
          garamontoNerdFont
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
            monospace = [ "GaramontoCode Nerd Font" ];
            sansSerif = [
              "EB Garamond"
              "Noto Sans"
            ];
            serif = [
              "EB Garamond"
              "Noto Serif"
            ];
            emoji = [ "Noto Color Emoji" ];
          };
        };
      };
    };
}
