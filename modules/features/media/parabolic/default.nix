{ self, inputs, ... }: {
  flake.nixosModules.parabolic = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.parabolic ];
  };
}
