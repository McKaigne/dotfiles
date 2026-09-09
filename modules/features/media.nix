{ self, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.mpv = pkgs.mpv;
    packages.kdenlive = pkgs.kdePackages.kdenlive;
    packages.obs-studio = pkgs.obs-studio;

    apps.mpv = {
      type = "app";
      program = "${pkgs.mpv}/bin/mpv";
      meta.description = "MPV media player";
    };
    apps.kdenlive = {
      type = "app";
      program = "${pkgs.kdePackages.kdenlive}/bin/kdenlive";
      meta.description = "Kdenlive non-linear video editor";
    };
    apps.obs-studio = {
      type = "app";
      program = "${pkgs.obs-studio}/bin/obs";
      meta.description = "OBS Studio streaming and recording software";
    };
  };

  flake = let
    nixosModule = { pkgs, ... }: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.mpv
        self.packages.${pkgs.stdenv.hostPlatform.system}.kdenlive
        self.packages.${pkgs.stdenv.hostPlatform.system}.obs-studio
      ];
    };
  in {
    nixosModules.media = nixosModule;
    nixosModules.castorConfiguration = nixosModule;
  };
}