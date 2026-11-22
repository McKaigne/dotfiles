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
    gui = "/etc/nixos/modules/programs/noctalia/config/gui.toml";

    # Noctalia saves the wallpaper per screen (hyde's DP-1, castor's eDP-1),
    # so a pick on one machine never reaches the other's screens. gui.toml is
    # synced, and wallpaper.last is the latest pick on either machine: when
    # it differs from what this machine shows, apply it to all its screens.
    # The machine that picked already matches, so nothing loops.
    follow = pkgs.writers.writePython3Bin "noctalia-wallpaper-follow" {flakeIgnore = ["E501"];} ''
      import glob
      import os
      import subprocess
      import tomllib

      noctalia = "${lib.getExe pkgs.noctalia}"

      try:
          with open("${gui}", "rb") as f:
              want = tomllib.load(f)["wallpaper"]["last"]["path"]
      except (OSError, KeyError, tomllib.TOMLDecodeError):
          raise SystemExit(0)
      if not os.path.isfile(want):
          raise SystemExit(0)

      for status in glob.glob("/sys/class/drm/card*-*/status"):
          with open(status) as f:
              if f.read().strip() != "connected":
                  continue
          screen = os.path.basename(os.path.dirname(status)).split("-", 1)[1]
          shown = subprocess.run(
              [noctalia, "msg", "wallpaper-get", screen],
              capture_output=True, text=True,
          ).stdout.strip()
          if shown and shown != want:
              subprocess.run([noctalia, "msg", "wallpaper-set", want])
              break
    '';
  in {
    # Re-check whenever the synced gui.toml changes.
    systemd.user.paths.noctalia-wallpaper-follow = {
      Unit.Description = "Follow wallpaper picks from the other machine";
      Path.PathChanged = gui;
      Install.WantedBy = ["default.target"];
    };
    systemd.user.services.noctalia-wallpaper-follow = {
      Unit.Description = "Apply the latest wallpaper pick to this machine's screens";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe follow;
      };
    };

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
