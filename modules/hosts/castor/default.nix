{ inputs, config, ... }:
let
  m = config.flake.modules;
in
{
  flake.nixosConfigurations.castor = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      m.nixos.host-workstation
      m.nixos.castor-hardware
      (
        { pkgs, ... }:
        {
          workstation = {
            username = "pollux";
            hostname = "castor";
            stateVersion = "25.05";
            system = "x86_64-linux";
            isDesktopCompute = false;
            display = {
              output = "eDP-1";
              mode = null;
              scale = "1.0";
              xftDpi = "141";
            };
          };

          boot.kernelParams = [
            "nowatchdog"
            "i915.enable_fbc=1"
          ];

          boot.extraModprobeConfig = ''
            options snd_hda_intel power_save=1 power_save_controller=Y
          '';

          boot.kernel.sysctl = {
            "vm.dirty_writeback_centisecs" = 6000;
            "vm.dirty_expire_centisecs" = 6000;
            "vm.dirty_ratio" = 20;
            "vm.dirty_background_ratio" = 5;
          };

          networking.networkmanager.wifi.powersave = true;

          services.thermald.enable = true;
          services.power-profiles-daemon.enable = true;
          services.upower.enable = true;

          hardware.graphics = {
            enable = true;
            extraPackages = with pkgs; [
              intel-media-driver
              libvdpau-va-gl
            ];
          };
          environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
        }
      )
    ];
  };
}
