{ self, inputs, ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    programs.xfconf.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    environment.systemPackages = with pkgs; [
      file-roller
      adwaita-icon-theme
      adw-gtk3

      # Archive utilities for .zip, .tar, .7z
      zip
      unzip
      p7zip
      gnutar
      gzip
      bzip2
      xz
      zstd
    ];

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
        "application/x-directory" = "thunar.desktop";
        "inode/mount-point" = "thunar.desktop";
        "x-scheme-handler/file" = "thunar.desktop";
      };
    };

    environment.sessionVariables = {
      FILEMANAGER = "thunar";
      TERMINAL = "ghostty";
    };
  };
}