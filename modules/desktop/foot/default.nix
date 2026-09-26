{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.foot
    ];
  };
in
{
  flake.nixosModules.foot = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }:
    let
      footConfig = pkgs.writeText "foot.ini" ''
        font = Maple Mono NF:size=14
        pad = 12x12
        term = xterm-256color

        [cursor]
        style = block
        blink = no

        [colors]
        alpha = 0.95

        # Noctalia live palette inclusion
        include = ~/.config/foot/themes/noctalia
      '';

      wrappedFoot = pkgs.symlinkJoin {
        name = "foot";
        paths = [ pkgs.foot ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/foot \
            --add-flags "--config=${footConfig}"
          wrapProgram $out/bin/footclient \
            --add-flags "--config=${footConfig}"
        '';
      };
    in
    {
      packages.foot = wrappedFoot;

      apps.foot = {
        type = "app";
        program = "${wrappedFoot}/bin/foot";
        meta.description = "Fast, lightweight Wayland terminal emulator with Noctalia theming";
      };
    };
}