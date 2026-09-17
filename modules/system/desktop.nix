{ ... }:
let
  desktopModule = { pkgs, ... }: {
    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
        "application/x-directory" = "thunar.desktop";
        "inode/mount-point" = "thunar.desktop";
        "x-scheme-handler/file" = "thunar.desktop";
        "text/plain" = "dev.zed.Zed.desktop";
        "text/x-c" = "dev.zed.Zed.desktop";
        "text/x-c++src" = "dev.zed.Zed.desktop";
        "text/x-c++hdr" = "dev.zed.Zed.desktop";
        "text/x-csrc" = "dev.zed.Zed.desktop";
        "text/x-chdr" = "dev.zed.Zed.desktop";
        "text/x-rust" = "dev.zed.Zed.desktop";
        "text/x-elixir" = "dev.zed.Zed.desktop";
        "application/json" = "dev.zed.Zed.desktop";

        # Archive manager associations
        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/x-zip-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
        "application/x-gzip" = "org.gnome.FileRoller.desktop";
        "application/x-bzip2" = "org.gnome.FileRoller.desktop";
        "application/x-xz" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        "application/vnd.rar" = "org.gnome.FileRoller.desktop";
      };
    };

    # Baseline workstation infrastructure & core utilities
    environment.systemPackages = with pkgs; [
      git
      curl
      ripgrep
      fd
      findutils
      wl-clipboard
      eza
      bat
      fetch
      antigravity-cli
      adwaita-icon-theme
      hicolor-icon-theme
      pavucontrol
      alsa-utils
      libnotify
    ];

    fonts.packages = with pkgs; [
      maple-mono.NF-unhinted
      maple-mono.truetype
      symbola
      nerd-fonts.symbols-only
    ];
  };
in
{
  flake.nixosModules.desktop = desktopModule;
}