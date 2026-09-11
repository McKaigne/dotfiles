{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.mpv
    ];
  };
in
{
  flake.nixosModules.mpv = nixosModule;
  flake.nixosModules.media = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.mpv = pkgs.mpv;

    apps.mpv = {
      type = "app";
      program = "${pkgs.mpv}/bin/mpv";
      meta.description = "MPV media player";
    };
  };
}