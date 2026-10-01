{ config, pkgs, inputs, lib, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  user = config.mainUser;
  rawYtm = inputs.ytm-player.packages.${system}.default or (pkgs.writeShellScriptBin "ytm" ''
    exec nix run "github:peternaame-boop/ytm-player" -- "$@"
  '');

  wrappedYtm = pkgs.symlinkJoin {
    name = "ytm-player";
    paths = [ rawYtm ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/ytm \
        --prefix PATH : "${lib.makeBinPath [ pkgs.mpv pkgs.ffmpeg pkgs.yt-dlp ]}"
    '';
  };
in
{
  environment.systemPackages = [ wrappedYtm ];

  home-manager.users.${user} = {
    xdg.configFile."ytm-player/config.toml" = {
      text = ''
        [general]
        theme = "noctalia"
        mouse_support = true
        show_lyrics = true
        lyrics_source = "lrclib"

        [player]
        backend = "mpv"
        mpris = true
        volume = 100
      '';
      force = true;
    };
  };
}
