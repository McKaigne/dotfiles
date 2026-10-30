_: {
  flake.nixosModules.obsidian = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.obsidian ];
  };
}
