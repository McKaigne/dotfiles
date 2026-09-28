{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zathura
      self.packages.${pkgs.stdenv.hostPlatform.system}.imv
      self.packages.${pkgs.stdenv.hostPlatform.system}.mpv
    ];
  };
in
{
  flake.nixosModules.viewers = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.zathura = pkgs.zathura;
    packages.imv = pkgs.imv;
    packages.mpv = pkgs.mpv;

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
    apps.mpv = {
      type = "app";
      program = "${pkgs.mpv}/bin/mpv";
      meta.description = "Media player";
    };
  };
}
