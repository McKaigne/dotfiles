_: {
  flake.nixosModules.nitch =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nitch ];
    };
}
