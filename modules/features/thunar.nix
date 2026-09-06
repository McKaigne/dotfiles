{ self, inputs, ... }: {
  flake.nixosModules.thunar = { pkgs, ... }: {
    programs.thunar = {
      enable = true;
      plugins = with pkgs; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

    # Storage mounting, trash, and network filesystem services
    services.gvfs.enable = true;

    # Thumbnail generation support for images and media files
    services.tumbler.enable = true;

    # GUI archive utility used by thunar-archive-plugin for context menu operations
    environment.systemPackages = with pkgs; [
      file-roller
    ];

    # Set Thunar as the system-wide default handler for directories
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
    };
  };
}
