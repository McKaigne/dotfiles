{ self, inputs, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.cliamp
    ];
  };
in
{
  flake.nixosModules.cliamp = nixosModule;

  perSystem = { self', pkgs, lib, system, ... }:
    let
      rawCliamp = inputs.cliamp.packages.${system}.default;

      noctaliaTheme = pkgs.writeText "noctalia.toml" ''
        bg = "#1e2326"
        accent = "#7fbbb3"
        bright_fg = "#d3c6aa"
        fg = "#7a8478"
        green = "#a7c080"
        yellow = "#dbbc7f"
        red = "#e67e80"
      '';

      # Exact cookie target for Helium browser
      cliampConfig = pkgs.writeText "config.toml" ''
        theme = "noctalia"
        start-theme = "noctalia"
        auto-play = false

        [ytmusic]
        cookies_from = "chromium:~/.config/net.imput.helium"
      '';

      cliampConfigDir = pkgs.runCommand "cliamp-config-dir" {} ''
        mkdir -p $out/cliamp/themes
        cp ${cliampConfig} $out/cliamp/config.toml
        cp ${noctaliaTheme} $out/cliamp/themes/noctalia.toml
      '';

      wrappedCliamp = pkgs.symlinkJoin {
        name = "cliamp";
        paths = [ rawCliamp ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cliamp \
            --prefix PATH : "${lib.makeBinPath [ pkgs.ffmpeg pkgs.yt-dlp ]}" \
            --prefix XDG_CONFIG_DIRS : "${cliampConfigDir}" \
            --add-flags "--start-theme noctalia"
        '';
      };
    in
    {
      packages.cliamp = wrappedCliamp;

      apps.cliamp = {
        type = "app";
        program = "${wrappedCliamp}/bin/cliamp";
        meta.description = "Terminal music player inspired by Winamp with Noctalia theme and YouTube Music sync";
      };
    };
}