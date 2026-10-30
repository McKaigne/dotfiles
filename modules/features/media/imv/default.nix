_: {
  flake.nixosModules.imv = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.imv ];
  };
}
