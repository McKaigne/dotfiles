{ self, ... }:
let
  desktopModule = { config, pkgs, lib, ... }: {
    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
        "application/x-directory" = "thunar.desktop";
        "inode/mount-point" = "thunar.desktop";
        "x-scheme-handler/file" = "thunar.desktop";
        "text/plain" = "emacsclient.desktop";
        "text/x-c" = "emacsclient.desktop";
        "text/x-c++src" = "emacsclient.desktop";
        "text/x-c++hdr" = "emacsclient.desktop";
        "text/x-csrc" = "emacsclient.desktop";
        "text/x-chdr" = "emacsclient.desktop";
        "text/x-rust" = "emacsclient.desktop";
        "text/x-elixir" = "emacsclient.desktop";
        "application/json" = "emacsclient.desktop";
      };
    };

    # Live Noctalia CSS Bridge for GTK 3 & 4
    environment.etc."xdg/gtk-3.0/gtk.css".text = ''
      @import url("file:///home/${config.mainUser}/.config/gtk-3.0/noctalia.css");
    '';
    environment.etc."xdg/gtk-4.0/gtk.css".text = ''
      @import url("file:///home/${config.mainUser}/.config/gtk-4.0/noctalia.css");
    '';

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
      fastfetch
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
  flake.nixosModules.castorConfiguration = desktopModule;
}