
{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    # Enable PAM authentication for screen lockers
    security.pam.services.hyprlock = {};

    environment.systemPackages = with pkgs; [
      # Screen Locker
      hyprlock

      # 3D fetch tool
      fetch

      # CLI & Monitoring
      fd
      ripgrep
      btop
      cava
      yazi

      # Base Utilities & Media
      git
      ghostty
      foot
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      bibata-cursors
      vim
      wget
      curl
    ];

    fonts.packages = with pkgs; [
      maple-mono.NF-unhinted
      maple-mono.truetype
      symbola
      nerd-fonts.symbols-only
    ];
  };
}
