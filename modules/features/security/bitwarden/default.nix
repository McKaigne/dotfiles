{ self, inputs, ... }: {
  flake.nixosModules.bitwarden = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];
  };
}
