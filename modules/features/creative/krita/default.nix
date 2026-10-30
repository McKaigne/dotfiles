_: {
  flake.nixosModules.krita = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.krita ];
  };
}
