{ self, inputs, ... }: {
  flake.nixosModules.helix = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix
    ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      wrappedHelix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ pkgs.helix ];
        postBuild = ''
          [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
        '';
      };
    in
    {
      packages.helix = wrappedHelix;

      apps.helix = {
        type = "app";
        program = "${wrappedHelix}/bin/hx";
        meta.description = "Helix modal text editor";
      };
    };
}