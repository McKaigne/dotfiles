{ inputs, ... }:
{
  flake.modules.nixos.noctalia-plymouth =
    { pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        theme = "noctalia";
        themePackages = [
          inputs.noctalia-plymouth.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
        font = "${pkgs.eb-garamond}/share/fonts/truetype/EBGaramond12-Regular.ttf";
      };
    };
}
