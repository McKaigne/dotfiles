{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
    ];
  };
in
{
  flake.nixosModules.fuzzel = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }:
    let
      fuzzelConfig = pkgs.writeText "fuzzel.ini" ''
        include=~/.config/fuzzel/themes/noctalia
      '';

      wrappedFuzzel = pkgs.symlinkJoin {
        name = "fuzzel";
        paths = [ pkgs.fuzzel ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/fuzzel \
            --add-flags "--config=${fuzzelConfig}"
        '';
      };
    in
    {
      packages.fuzzel = wrappedFuzzel;

      apps.fuzzel = {
        type = "app";
        program = "${wrappedFuzzel}/bin/fuzzel";
        meta.description = "Hermetically wrapped Fuzzel application launcher";
      };
    };
}