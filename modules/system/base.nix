{ config, lib, ... }:
let
  hmBase = config.homeManager.base;
in
{
  options = {
    nixos.base = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Shared operating-system defaults for the desktop hosts.";
    };
    homeManager.base = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Shared user-session defaults attached by the system base.";
    };
  };

  config.nixos.base =
    { config, ... }:
    {
      home-manager.sharedModules = [ hmBase ];
      assertions = [
        {
          assertion =
            (config.swapDevices == [ ])
            -> (
              config.boot.kernel.sysctl."vm.swappiness" or 0 == 180
              && config.boot.kernel.sysctl."vm.watermark_scale_factor" or 0 == 125
              && config.boot.kernel.sysctl."vm.page-cluster" or (-1) == 0
            );
          message =
            "Pure ZRAM hosts must set vm.swappiness = 180, "
            + "vm.watermark_scale_factor = 125, and vm.page-cluster = 0 "
            + "to prevent cache thrashing.";
        }
      ];
    };
}
