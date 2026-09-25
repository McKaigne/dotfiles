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
        "text/plain" = "emacsclient.desktop";
        "text/x-c" = "emacsclient.desktop";
        "text/x-c++src" = "emacsclient.desktop";
        "text/x-c++hdr" = "emacsclient.desktop";
        "text/x-csrc" = "emacsclient.desktop";
        "text/x-chdr" = "emacsclient.desktop";
        "text/x-rust" = "emacsclient.desktop";
        "text/x-elixir" = "emacsclient.desktop";
        "application/json" = "emacsclient.desktop";

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
  flake.nixosModules.castorConfiguration = desktopModule;
}