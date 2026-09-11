{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.cava
    ];
  };
in
{
  flake.nixosModules.cava = nixosModule;

  perSystem = { pkgs, ... }:
    let
      cavaConfig = pkgs.writeText "cava-config" ''
        [general]
        framerate = 60
        autosens = 1
        bars = 0
        bar_width = 2
        bar_spacing = 1
        lower_cutoff_freq = 50
        higher_cutoff_freq = 10000

        [input]
        method = pipewire
        source = auto

        [output]
        method = noncurses
        orientation = bottom
        channels = stereo

        [color]
        background = default
        foreground = default

        [smoothing]
        monstercat = 0
        waves = 0
        noise_reduction = 77
      '';

      wrappedCava = pkgs.symlinkJoin {
        name = "cava";
        paths = [ pkgs.cava ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cava \
            --add-flags "-p ${cavaConfig}"
        '';
      };
    in
    {
      packages.cava = wrappedCava;

      apps.cava = {
        type = "app";
        program = "${wrappedCava}/bin/cava";
        meta.description = "Hermetically wrapped CAVA audio visualizer";
      };
    };
}