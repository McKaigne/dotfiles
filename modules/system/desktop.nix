{ inputs, ... }:
let
  desktopModule = { pkgs, ... }: {
    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "superfile.desktop";
        "application/x-directory" = "superfile.desktop";
        "inode/mount-point" = "superfile.desktop";
        "x-scheme-handler/file" = "superfile.desktop";
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

      # Development Tooling & Highlighting
      nnn
      direnv
      pkgs.devenv
      delta

      # Downloaders & Extractors
      yt-dlp
      aria2
      p7zip
      unrar
    ];

    environment.etc."gitconfig".text = ''
      [core]
        pager = delta

      [interactive]
        diffFilter = delta --color-only

      [delta]
        navigate = true
        light = false
        line-numbers = true
        side-by-side = false
        syntax-theme = "base16"
    '';

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