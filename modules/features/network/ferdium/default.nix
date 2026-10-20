{ self, inputs, ... }: {
  flake.nixosModules.ferdium = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.ferdium ];
  };
}
