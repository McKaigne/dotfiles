{
  flake.modules.homeManager."noctalia" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    # Plain folder in home: drop images in, no rebuild needed.
    dir = "${config.home.homeDirectory}/Pictures/Wallpapers";
    seed = ../../../../assets/default-wallpaper.jpg;
  in {
    # Give a fresh machine (e.g. castor) the default wallpaper; never overwrite.
    home.activation.seedWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
      run mkdir -p ${lib.escapeShellArg dir}
      if [ ! -e ${lib.escapeShellArg "${dir}/isekaiJoucho.jpg"} ]; then
        run install -m 0644 ${seed} ${lib.escapeShellArg "${dir}/isekaiJoucho.jpg"}
      fi
    '';

    xdg.configFile."noctalia/43-wallpapers.toml".source = (pkgs.formats.toml {}).generate "43-wallpapers.toml" {
      "wallpaper" = {
        "directory" = dir;
        "transition" = [
          "melt"
        ];
        "default" = {
          "path" = "${dir}/isekaiJoucho.jpg";
        };
      };
    };
  };
}
