{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.pcmanfm = {pkgs, ...}: {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.pcmanfm];
    environment.systemPackages = with pkgs; [
      pcmanfm
      xarchiver
      libfm
      lxmenu-data
      shared-mime-info
      cliphist
      satty
      wl-mirror
    ];
  };

  flake.modules.homeManager.pcmanfm = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm.desktop";
        "application/x-directory" = "pcmanfm.desktop";
        "inode/mount-point" = "pcmanfm.desktop";
        "x-scheme-handler/file" = "pcmanfm.desktop";

        "text/html" = "librewolf.desktop";
        "x-scheme-handler/http" = "librewolf.desktop";
        "x-scheme-handler/https" = "librewolf.desktop";

        "application/pdf" = "org.pwmt.zathura.desktop";

        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/svg+xml" = "imv.desktop";

        "video/mp4" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/quicktime" = "mpv.desktop";

        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";
      };
    };

    xdg.configFile."pcmanfm/default/pcmanfm.conf" = {
      text = ''
        [config]
        bm_open_method=0
        terminal=foot

        [volume]
        mount_on_removable=1
        mount_removable=1
        autorun=1

        [ui]
        always_show_tabs=0
        max_tab_chars=32
        win_width=900
        win_height=600
        splitter_pos=180
        side_pane_mode=dirtree
        view_mode=detailed
        show_hidden=1
        show_statusbar=0
        sort_type=0
        sort_by=0
      '';
      force = true;
    };
  };
}
