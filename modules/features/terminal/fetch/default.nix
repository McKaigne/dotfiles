{ self, inputs, ... }: {
  flake.nixosModules.fetch =
    { pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      fetchPackage = inputs.fetch.packages.${system}.default;
    in
    {
      environment.systemPackages = [ fetchPackage ];
    };
}
