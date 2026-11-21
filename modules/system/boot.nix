{
  nixos.base =
    { lib, ... }:
    {
      boot.loader.systemd-boot = {
        enable = true;
        editor = false;
        configurationLimit = 10;
      };
      boot.loader.efi.canTouchEfiVariables = true;

      boot.tmp = {
        useTmpfs = true;
        tmpfsSize = "50%";
      };

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
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 1024;
      };
    };
}
