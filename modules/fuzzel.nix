
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

  perSystem = { pkgs, ... }:
    let
      fuzzelConfig = pkgs.writeText "fuzzel.ini" ''
        [main]
        font=Maple Mono NF:size=14
        prompt="➜ "
        lines=12
        width=35
        horizontal-pad=20
        vertical-pad=15
        inner-pad=10
        include=~/.config/fuzzel/themes/noctalia
      '';

      wrappedFuzzel = pkgs.symlinkJoin {
        name = "fuzzel";
        paths = [ pkgs.fuzzel ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
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
        meta.description = "Hermetically wrapped Fuzzel launcher with dynamic Noctalia theme";
      };
    };
}
