{
  inputs,
  config,
  ...
}: let
  m = config.flake.modules;
in {
  nixos.base = {
    config,
    lib,
    ...
  }: {
    imports = [inputs.home-manager.nixosModules.home-manager];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "backup";
      overwriteBackup = true;
      extraSpecialArgs = {inherit inputs;};
      sharedModules = [
        m.generic.workstation-options
        {
          workstation = {
            inherit
              (config.workstation)
              username
              hostname
              stateVersion
              system
              desktop
              screenWidth
              git
              ;
          };
        }
      ];
    };
    systemd.services."home-manager-${config.workstation.username}".serviceConfig.TimeoutStartSec =
      lib.mkForce "30m";
  };
}
