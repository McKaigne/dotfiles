
{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.easyeffects
    ];
  };
in
{
  flake.nixosModules.easyeffects = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.easyeffects = pkgs.easyeffects;

    apps.easyeffects = {
      type = "app";
      program = "${pkgs.easyeffects}/bin/easyeffects";
      meta.description = "PipeWire audio effects processor and equalizer";
    };
  };
}
