{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zathura
      self.packages.${pkgs.stdenv.hostPlatform.system}.imv
    ];
  };
in
{
  flake.nixosModules.viewers = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.zathura = pkgs.zathura;
    packages.imv = pkgs.imv;

    apps.zathura = {
      type = "app";
      program = "${pkgs.zathura}/bin/zathura";
      meta.description = "Document viewer";
    };
    apps.imv = {
      type = "app";
      program = "${pkgs.imv}/bin/imv";
      meta.description = "Wayland native image viewer";
    };
  };
}