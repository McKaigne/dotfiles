_: {
  flake.nixosModules.kdenlive = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.kdePackages.kdenlive ];
  };
}
