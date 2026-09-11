{ self, inputs, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
    ];
  };
in
{
  flake.nixosModules.noctalia = nixosModule;

  perSystem = { pkgs, ... }:
    let
      wrappedNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
      };
    in
    {
      packages.noctalia-shell = wrappedNoctalia;

      apps.noctalia-shell = {
        type = "app";
        program = "${wrappedNoctalia}/bin/noctalia-shell";
        meta.description = "Noctalia Wayland desktop shell";
      };
    };
}