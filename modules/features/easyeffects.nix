{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.easyeffects
    ];

    # Background service: audio processing persists even when the GUI window is closed
    systemd.user.services.easyeffects = {
      description = "EasyEffects Audio Daemon";
      wantedBy = [ "graphical-session.target" ];
      partOf = [ "pipewire.service" ];
      after = [ "pipewire.service" ];
      serviceConfig = {
        ExecStart = "${self.packages.${pkgs.stdenv.hostPlatform.system}.easyeffects}/bin/easyeffects --gapplication-service";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
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