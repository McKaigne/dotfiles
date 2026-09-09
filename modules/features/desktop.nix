{ self, ... }: {
  flake.nixosModules.desktop = { config, pkgs, lib, ... }: {
    security.pam.services.hyprlock = { };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "antigravity-cli"
        "zed-editor"
      ];

    xdg.mime = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "thunar.desktop";
        "application/x-directory" = "thunar.desktop";
        "inode/mount-point" = "thunar.desktop";
        "x-scheme-handler/file" = "thunar.desktop";
        "text/plain" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-c" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-c++src" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-c++hdr" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-csrc" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-chdr" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-rust" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "text/x-elixir" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
        "application/json" = [ "emacsclient.desktop" "dev.zed.Zed.desktop" ];
      };
    };

    # Live Noctalia CSS Bridge for GTK 3 & 4
    environment.etc."xdg/gtk-3.0/gtk.css".text = ''
      @import url("file:///home/${config.mainUser}/.config/gtk-3.0/noctalia.css");
    '';
    environment.etc."xdg/gtk-4.0/gtk.css".text = ''
      @import url("file:///home/${config.mainUser}/.config/gtk-4.0/noctalia.css");
    '';

    environment.systemPackages = with pkgs; [
      bat
      fd
      ripgrep
      btop
      fetch
      zoxide
      antigravity-cli

      hyprlock
      overskride
      bluez
      bluez-tools

      git
      foot
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      vim
      wget
      curl

      pavucontrol
      alsa-utils

      kdePackages.kdenlive
      mpv
      obs-studio
      zed-editor
      zathura
      feh
    ];

    fonts.packages = with pkgs; [
      maple-mono.NF-unhinted
      maple-mono.truetype
      symbola
      nerd-fonts.symbols-only
    ];
  };
}