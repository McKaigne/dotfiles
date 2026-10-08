{ self, inputs, ... }: {
  perSystem = { pkgs, lib, system, ... }:
  let
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
    packages.myCliamp = wrappedCliamp;
  };

  flake.nixosModules.cliamp = { config, pkgs, ... }:
  let
    user = config.mainUser;
    system = pkgs.stdenv.hostPlatform.system;
  in
  {
    environment.systemPackages = [ self.packages.${system}.myCliamp ];

    home-manager.users.${user} = { lib, ... }: {
      home.activation.setupCliampConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.config/cliamp/themes
        if [ ! -f $HOME/.config/cliamp/config.toml ]; then
          cat <<'EOF' > $HOME/.config/cliamp/config.toml
theme = "noctalia"
visualizer = "Retro"
provider = "ytmusic"
eq_preset = "Flat"
eq = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
volume = 80
expanded = true
hide_help_bar = true
hide_settings_pane = true
vis_volume_linked = false

[ytmusic]
enabled = true
cookies_from = "brave+gnomekeyring"
EOF
          chmod 644 $HOME/.config/cliamp/config.toml
        fi
      '';
    };
  };
}
