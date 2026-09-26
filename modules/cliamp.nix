
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
            --prefix PATH : "${lib.makeBinPath [ pkgs.ffmpeg pkgs.yt-dlp pkgs.gnused pkgs.jq ]}" \
            --run '
              CLIAMP_RUNTIME="''${XDG_RUNTIME_DIR:-/tmp}/cliamp-config-''${USER}"
              mkdir -p "$CLIAMP_RUNTIME/cliamp/themes"
              ${pkgs.gnused}/bin/sed "s|@USER_HOME@|$HOME|g" "${cliampConfigTemplate}" > "$CLIAMP_RUNTIME/cliamp/config.toml"

              # Derive colors dynamically from Noctalia colors.json if present
              COLORS_JSON="$HOME/.config/noctalia/colors.json"
              if [ -f "$COLORS_JSON" ]; then
                ACCENT=$(${pkgs.jq}/bin/jq -r '\'' .mPrimary // "#cba6f7" '\'' "$COLORS_JSON")
                BRIGHT_FG=$(${pkgs.jq}/bin/jq -r '\'' .mOnSurface // "#cdd6f4" '\'' "$COLORS_JSON")
                FG=$(${pkgs.jq}/bin/jq -r '\'' .mOnSurfaceVariant // "#a3b4eb" '\'' "$COLORS_JSON")
                GREEN=$(${pkgs.jq}/bin/jq -r '\'' .mTertiary // "#94e2d5" '\'' "$COLORS_JSON")
                YELLOW=$(${pkgs.jq}/bin/jq -r '\'' .mSecondary // "#fab387" '\'' "$COLORS_JSON")
                RED=$(${pkgs.jq}/bin/jq -r '\'' .mError // "#f38ba8" '\'' "$COLORS_JSON")
              else
                ACCENT="#cba6f7"; BRIGHT_FG="#cdd6f4"; FG="#a6adc8"
                GREEN="#a6e3a1"; YELLOW="#f9e2af"; RED="#f38ba8"
              fi

              cat << EOF > "$CLIAMP_RUNTIME/cliamp/themes/noctalia.toml"
accent = "$ACCENT"
bright_fg = "$BRIGHT_FG"
fg = "$FG"
green = "$GREEN"
yellow = "$YELLOW"
red = "$RED"
EOF
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
        meta.description = "Terminal music player dynamically synced with active Noctalia theme";
      };
    };
}
