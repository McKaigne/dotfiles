{ self, inputs, ... }: {
  flake.nixosModules.onlyoffice = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
