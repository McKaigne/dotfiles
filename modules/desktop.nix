
{ inputs, ... }:
let
  desktopModule = { config, pkgs, ... }: {
    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    environment.etc."xdg/direnv/direnv.toml".text = ''
      [whitelist]
      prefix = [
        "/home/${config.mainUser}/Projects",
        "/home/${config.mainUser}/projects"
      ]
    '';

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "superfile.desktop";
        "application/x-directory" = "superfile.desktop";
        "inode/mount-point" = "superfile.desktop";
        "x-scheme-handler/file" = "superfile.desktop";

        "text/plain" = "helix.desktop";
        "text/markdown" = "helix.desktop";
        "text/x-nix" = "helix.desktop";
        "application/json" = "helix.desktop";
        "application/x-yaml" = "helix.desktop";

        "application/zip" = "org.gnome.FileRoller.desktop";
        "application/x-zip-compressed" = "org.gnome.FileRoller.desktop";
        "application/x-tar" = "org.gnome.FileRoller.desktop";
        "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
        "application/x-gzip" = "org.gnome.FileRoller.desktop";
        "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
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
      fetch              # aerofyl's animated 3D fetch
      file-roller
      adwaita-icon-theme
      hicolor-icon-theme
      pavucontrol
      alsa-utils
      libnotify
      direnv
      devenv
      delta
      yt-dlp
      aria2
      p7zip
      unrar
    ];

    environment.etc."gitconfig".text = ''
      [core]
        pager = delta
        editor = hx

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
      symbola
      nerd-fonts.symbols-only
    ];
  };
in
{
  flake.nixosModules.desktop = desktopModule;
}
