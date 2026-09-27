
{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.btop
    ];
  };
in
{
  flake.nixosModules.btop = nixosModule;

  perSystem = { pkgs, ... }:
    let
      # Wrapper passes --config only. Btop searches ~/.config/btop/themes natively at runtime.
      wrappedBtop = pkgs.symlinkJoin {
        name = "btop";
        paths = [ pkgs.btop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop \
            --add-flags "--config ${./btop.conf}"
        '';
      };
    in
    {
      packages.btop = wrappedBtop;

      apps.btop = {
        type = "app";
        program = "${wrappedBtop}/bin/btop";
        meta.description = "Btop monitor loading Noctalia theme from ~/.config/btop/themes";
      };
    };
}
