
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

        [colors]
        background=1e1e2eff
        text=cdd6f4ff
        match=cba6f7ff
        selection=313244ff
        selection-text=cdd6f4ff
        selection-match=cba6f7ff
        border=cba6f7ff

        [border]
        width=2
        radius=12
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
        meta.description = "Hermetically wrapped Fuzzel launcher";
      };
    };
}
