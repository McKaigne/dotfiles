{
  flake.modules.nixos.blender = {pkgs, ...}: {
    environment.systemPackages = [pkgs.pkgsRocm.blender];
  };
}
