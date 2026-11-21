{
  inputs,
  config,
  ...
}: let
  m = config.flake.modules;
  mkHost = import ../_mkHost.nix {inherit inputs m;};
in {
  flake.nixosConfigurations.castor = mkHost "castor" {
    username = "pollux";
    hostname = "castor";
    stateVersion = "25.05";
    system = "x86_64-linux";

    # Active compositor, change here to switch sessions.
    desktop = "umbriel";
    # desktop = "niri";

    git = {
      name = "McKaigne";
      email = "abellorchristian2007@gmail.com";
    };
  };

  flake.modules.nixos.host-castor = {pkgs, ...}: {
    imports = [m.nixos.castor-hardware];

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
    services.upower.enable = true;

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        libvdpau-va-gl
      ];
    };
    environment.sessionVariables = {
      LIBVA_DRIVER_NAME = "iHD";
      XFT_DPI = "141";
    };

    services.displayManager.noctalia-greeter.settings.output.name = "eDP-1";
  };
}
