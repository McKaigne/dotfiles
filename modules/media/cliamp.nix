{ config, pkgs, inputs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  user = config.mainUser;
  rawCliamp = inputs.cliamp.packages.${system}.default or (pkgs.writeShellScriptBin "cliamp" ''
    exec nix run "github:bjarneo/cliamp" -- "$@"
  '');

  wrappedCliamp = pkgs.symlinkJoin {
    name = "cliamp";
    paths = [ rawCliamp ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/cliamp \
        --prefix PATH : "${lib.makeBinPath [ pkgs.yt-dlp pkgs.ffmpeg ]}"
    '';
  };
in
{
  environment.systemPackages = [ wrappedCliamp ];

  home-manager.users.${user} = { lib, ... }: {
    home.activation.setupCliampConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p $HOME/.config/cliamp
      rm -f $HOME/.config/cliamp/config.toml
      cat <<'EOF' > $HOME/.config/cliamp/config.toml
theme = "noctalia"
visualizer = "Terrain"
provider = "ytmusic"
eq_preset = "Flat"
eq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
volume = 80
hide_help_bar = true
hide_settings_pane = true
vis_volume_linked = false
compact = false

[ytmusic]
enabled = true
cookies_from = "chromium+gnomekeyring:/home/${user}/.config/net.imput.helium"
EOF
      chmod 600 $HOME/.config/cliamp/config.toml
    '';
  };
}
