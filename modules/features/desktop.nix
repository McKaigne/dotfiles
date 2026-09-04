
{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    security.pam.services.hyprlock = {};

    environment.systemPackages = with pkgs; [
      # CLI & Monitoring Tools
      bat
      fd
      ripgrep
      btop
      cava
      yazi
      fetch

      # Screen Locker & Bluetooth
      hyprlock
      overskride
      bluez
      bluez-tools

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
