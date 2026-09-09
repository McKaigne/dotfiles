{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, lib, ... }: {
    security.pam.services.hyprlock = { };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "antigravity-cli"
        "zed-editor"
      ];

    environment.systemPackages = with pkgs; [
      bat
      fd
      ripgrep
      btop
      cava
      yazi
      fetch
      zoxide
      antigravity-cli

      hyprlock
      overskride
      bluez
      bluez-tools

      git
      ghostty
      foot
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      vim
      wget
      curl

      # Audio control
      pavucontrol
      alsa-utils

      # Media & Viewers
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