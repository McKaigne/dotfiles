_: {
  flake.nixosModules.hostBase =
    { lib, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.systemd-boot.editor = false;
      boot.loader.systemd-boot.configurationLimit = 10;
      boot.loader.efi.canTouchEfiVariables = true;

      boot.tmp.useTmpfs = true;
      boot.tmp.tmpfsSize = "50%";

      zramSwap = {
        enable = true;
        algorithm = "zstd";
        memoryPercent = 50;
      };

      boot.kernel.sysctl = {
        "vm.swappiness" = lib.mkDefault 180;
        "vm.watermark_boost_factor" = lib.mkDefault 0;
        "vm.watermark_scale_factor" = lib.mkDefault 125;
        "vm.page-cluster" = lib.mkDefault 0;
      };

      networking.networkmanager.enable = true;
      services.fstrim.enable = true;
    };
}
