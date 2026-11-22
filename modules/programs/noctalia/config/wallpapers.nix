let
  # One folder at the same path on every machine, so the wallpaper paths
  # Noctalia saves in the shared gui.toml mean the same thing on hyde and
  # castor (whose home directories differ). Drop images in, no rebuild needed.
  dir = "/var/lib/wallpapers";
in {
  flake.modules.nixos."noctalia" = {config, ...}: {
    systemd.tmpfiles.settings."10-wallpapers".${dir}.d = {
      user = config.workstation.username;
      group = config.users.users.${config.workstation.username}.group;
      mode = "0755";
    };
  };

  flake.modules.homeManager."noctalia" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    home = "${config.home.homeDirectory}/Pictures/Wallpapers";
    seed = ../../../../assets/default-wallpaper.jpg;
  in {
    # ~/Pictures/Wallpapers becomes a link to the shared folder: anything
    # already in it moves across (never overwriting), so old paths still
    # resolve through the link. A fresh machine gets the default wallpaper.
    home.activation.seedWallpapers = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -d ${dir} ] && [ -w ${dir} ]; then
        if [ -d ${lib.escapeShellArg home} ] && [ ! -L ${lib.escapeShellArg home} ]; then
          run find ${lib.escapeShellArg home} -mindepth 1 -maxdepth 1 \
            -exec mv -n -t ${dir} {} +
          run rmdir ${lib.escapeShellArg home} 2>/dev/null || true
        fi
        if [ ! -e ${lib.escapeShellArg home} ]; then
          run mkdir -p "$(dirname ${lib.escapeShellArg home})"
          run ln -s ${dir} ${lib.escapeShellArg home}
        fi
        if [ ! -e ${dir}/isekaiJoucho.jpg ]; then
          run install -m 0644 ${seed} ${dir}/isekaiJoucho.jpg
        fi
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
