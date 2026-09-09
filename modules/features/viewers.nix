{ self, ... }:
{
  perSystem = { pkgs, ... }: {
    packages.zathura = pkgs.zathura;
    packages.feh = pkgs.feh;

    apps.zathura = {
      type = "app";
      program = "${pkgs.zathura}/bin/zathura";
      meta.description = "Document viewer";
    };
    apps.feh = {
      type = "app";
      program = "${pkgs.feh}/bin/feh";
      meta.description = "Image viewer";
    };
  };

  flake = let
    nixosModule = { pkgs, ... }: {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.zathura
        self.packages.${pkgs.stdenv.hostPlatform.system}.feh
      ];
    };
  in {
    nixosModules.viewers = nixosModule;
    nixosModules.castorConfiguration = nixosModule;
  };
}