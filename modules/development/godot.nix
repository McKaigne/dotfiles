{
  flake.modules.nixos.godot = {pkgs, ...}: {
    environment.systemPackages = [pkgs.godot_4];
  };
}
