_: {
  flake.nixosModules.blender = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.pkgsRocm.blender ];
  };
}
