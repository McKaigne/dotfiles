{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = with pkgs.kdePackages; [
      dolphin
      breeze-icons
      kio-extras
      kio-fuse
      kdegraphics-thumbnailers
      ffmpegthumbs
    ];
  };
in
{
  flake.nixosModules.dolphin = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.dolphin = pkgs.kdePackages.dolphin;

    apps.dolphin = {
      type = "app";
      program = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      meta.description = "KDE Dolphin GUI file manager with Noctalia KColorScheme auto-theming";
    };
  };
}