
{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix
    ];
  };
in
{
  flake.nixosModules.helix = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      wrappedHelix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${lib.makeBinPath [ pkgs.marksman pkgs.gnused ]}"
          [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
        '';
      };
    in
    {
      packages.helix = wrappedHelix;

      apps.helix = {
        type = "app";
        program = "${wrappedHelix}/bin/hx";
        meta.description = "Helix modal editor with language server integration";
      };
    };
}
