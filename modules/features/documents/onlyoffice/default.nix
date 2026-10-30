_: {
  flake.nixosModules.onlyoffice = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.onlyoffice-desktopeditors ];
  };
}
