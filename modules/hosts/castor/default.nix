{ self, inputs, ... }: {
  flake.nixosConfigurations.castor = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.castorHardware
      self.nixosModules.baseWorkstation
      ({ pkgs, ... }: {
        networking.hostName = "castor";
        mainUser = "pollux";
        environment.sessionVariables.XFT_DPI = "141";
        time.timeZone = "Asia/Manila";

        workstation.display = {
          output = "eDP-1";
          mode = null;
          scale = "1.0";
        };

        boot.kernelParams = [
          "nowatchdog"
          "i915.enable_fbc=1"
        ];

        boot.extraModprobeConfig = ''
          options snd_hda_intel power_save=1 power_save_controller=Y
        '';

        # Mobile dirty writeback tuning
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

        # Intel Iris Xe graphics
        hardware.graphics = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            libvdpau-va-gl
          ];
        };
        environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

        system.stateVersion = "25.05";
      })
    ];
  };
}
