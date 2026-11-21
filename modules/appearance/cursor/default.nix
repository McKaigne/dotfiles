{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.cursor = {config, ...}: {
    imports = [flakeConfig.flake.modules.generic.cursor];
    environment.systemPackages = [config.workstation.cursor.package];
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.cursor];
  };
  flake.modules.homeManager.cursor.imports = [config.flake.modules.generic.cursor];
}
