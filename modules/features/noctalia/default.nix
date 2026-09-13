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
      rawNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
        inherit pkgs;
      };

      wrappedNoctalia = pkgs.symlinkJoin {
        name = "noctalia-shell";
        paths = [ rawNoctalia ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/noctalia-shell \
            --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin" \
            --prefix XDG_DATA_DIRS : "/run/current-system/sw/share"
        '';
      };
    in
    {
      packages.noctalia-shell = wrappedNoctalia;

      apps.noctalia-shell = {
        type = "app";
        program = "${wrappedNoctalia}/bin/noctalia-shell";
        meta.description = "Noctalia Wayland desktop shell wrapped with desktop paths";
      };
    };
}