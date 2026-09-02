{ self, inputs, ... }: {
  flake.nixosModules.castorHardware = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.extraModulePackages = [ ];

    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      # fallback if UUID is used
      fsType = "ext4";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    swapDevices = [ ];

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
