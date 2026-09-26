
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

  perSystem = { pkgs, lib, system, ... }:
    let
      rawCliamp = inputs.cliamp.packages.${system}.default;

      noctaliaTheme = pkgs.writeText "noctalia.toml" ''
        accent = "#cba6f7"
        bright_fg = "#cdd6f4"
        fg = "#a6adc8"
        green = "#a6e3a1"
        yellow = "#f9e2af"
        red = "#f38ba8"
      '';

      cliampConfigTemplate = pkgs.writeText "config.toml.template" ''
        theme = "noctalia"
        start-theme = "noctalia"
        auto-play = false

        [ytmusic]
        enabled = true
        cookies_from = "chromium+basictext:@USER_HOME@/.config/net.imput.helium"
      '';

      wrappedCliamp = pkgs.symlinkJoin {
        name = "cliamp";
        paths = [ rawCliamp ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cliamp \
            --prefix PATH : "${lib.makeBinPath [ pkgs.ffmpeg pkgs.yt-dlp pkgs.gnused ]}" \
            --run '
              CLIAMP_RUNTIME="''${XDG_RUNTIME_DIR:-/tmp}/cliamp-config-''${USER}"
              mkdir -p "$CLIAMP_RUNTIME/cliamp/themes"
              ${pkgs.gnused}/bin/sed "s|@USER_HOME@|$HOME|g" "${cliampConfigTemplate}" > "$CLIAMP_RUNTIME/cliamp/config.toml"
              cp -f "${noctaliaTheme}" "$CLIAMP_RUNTIME/cliamp/themes/noctalia.toml"
              export XDG_CONFIG_HOME="$CLIAMP_RUNTIME"
            ' \
            --add-flags "--start-theme noctalia"
        '';
      };
    in
    {
      packages.cliamp = wrappedCliamp;

      apps.cliamp = {
        type = "app";
        program = "${wrappedCliamp}/bin/cliamp";
        meta.description = "Terminal music player with Noctalia theme and Helium YouTube Music cookie sync";
      };
    };
}
