{ self, inputs, ... }: {
  flake.nixosModules.zennotes = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.zennotes-desktop ];
  };
}
