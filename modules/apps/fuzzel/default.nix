{ config, pkgs, ... }:
let
  user = config.mainUser;
  wrappedFuzzel = pkgs.symlinkJoin {
    name = "fuzzel";
    paths = [ pkgs.fuzzel ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/fuzzel \
        --add-flags "--config=${./fuzzel.ini}"
    '';
  };
in
{
  environment.systemPackages = [ wrappedFuzzel ];

  home-manager.users.${user} = {
    xdg.configFile."fuzzel/fuzzel.ini" = {
      source = ./fuzzel.ini;
      force = true;
    };
  };
}
