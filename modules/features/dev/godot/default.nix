{ self, inputs, ... }: {
  flake.nixosModules.godot = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.godot_4 ];
  };
}
