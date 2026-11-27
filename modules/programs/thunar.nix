{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.thunar = {pkgs, ...}: {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.thunar];
    programs.thunar = {
      enable = true;
      # Context-menu create/extract, removable-media handling, audio tags.
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
        thunar-media-tags-plugin
      ];
    };
    environment.systemPackages = with pkgs; [
      # thunar-archive-plugin hands archives to xarchiver, which shells out
      # to these for each format.
      xarchiver
      zip
      unzip
      p7zip
      unrar
      gnutar
      xz
      zstd
      # Thumbnails through tumbler (services.tumbler, system/files.nix).
      ffmpegthumbnailer
      webp-pixbuf-loader
      libgsf
      poppler
      shared-mime-info
      cliphist
      satty
      wl-mirror
    ];
  };

  flake.modules.homeManager.thunar = {pkgs, ...}: let
    archives = [
      "application/zip"
      "application/x-7z-compressed"
      "application/vnd.rar"
      "application/x-rar"
      "application/x-tar"
      "application/x-compressed-tar"
      "application/x-bzip-compressed-tar"
      "application/x-xz-compressed-tar"
      "application/x-zstd-compressed-tar"
      "application/gzip"
      "application/x-bzip"
      "application/x-xz"
      "application/zstd"
    ];
  in {
    xfconf.settings.thunar = {
      misc-open-new-windows-in-split-view = true;
      last-show-hidden = true;
      last-view = "ThunarDetailsView";
      last-menubar-visible = false;
      last-side-pane = "ThunarShortcutsPane";
      misc-thumbnail-mode = "THUNAR_THUMBNAIL_MODE_ALWAYS";
      misc-middle-click-in-tab = true;
      misc-file-size-binary = true;

      # The usual clean Thunar: symbolic 16px icons, breadcrumbs instead of
      # a path entry, no status bar, three columns. Styling lives in the
      # GTK3 glass template (noctalia/templates/gtk3-thunar.css).
      misc-symbolic-icons-in-sidepane = true;
      misc-symbolic-icons-in-toolbar = true;
      misc-small-toolbar-icons = true;
      shortcuts-icon-size = "THUNAR_ICON_SIZE_16";
      tree-icon-size = "THUNAR_ICON_SIZE_16";
      last-location-bar = "ThunarLocationButtons";
      last-statusbar-visible = false;
      last-separator-position = 170;
      last-details-view-zoom-level = "THUNAR_ZOOM_LEVEL_38_PERCENT";
      last-icon-view-zoom-level = "THUNAR_ZOOM_LEVEL_75_PERCENT";
      last-details-view-visible-columns = "THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_DATE_MODIFIED";
      # Fixed widths that fit a split pane; auto-sizing stretches Name to the
      # longest file name and pushes the other columns off-screen. Widths
      # are indexed by Thunar's column enum (Date Modified 2, Name 8, Size 11).
      last-details-view-fixed-columns = true;
      last-details-view-column-widths = "50,50,130,50,50,50,50,50,200,50,50,80,50,50";
      misc-thumbnail-draw-frames = false;
    };

    # Thunar's stock "Open Terminal Here" goes through the Xfce helper
    # framework, which isn't installed; call foot directly.
    xdg.configFile."Thunar/uca.xml" = {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <unique-id>nixos-foot-here</unique-id>
          <command>${pkgs.foot}/bin/foot --working-directory=%f</command>
          <description>Open foot in this folder</description>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        <action>
          <icon>emacs</icon>
          <name>Open in Emacs</name>
          <unique-id>nixos-emacs-open</unique-id>
          <command>emacs %F</command>
          <description>Open in an Emacs frame</description>
          <patterns>*</patterns>
          <directories/>
          <text-files/>
          <other-files/>
        </action>
        </actions>
      '';
      force = true;
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications =
        {
          "inode/directory" = "thunar.desktop";
          "application/x-directory" = "thunar.desktop";
          "inode/mount-point" = "thunar.desktop";
          "x-scheme-handler/file" = "thunar.desktop";
          "x-scheme-handler/trash" = "thunar.desktop";

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
        }
        // builtins.listToAttrs (map (t: {
            name = t;
            value = "xarchiver.desktop";
          })
          archives);
    };
  };
}
