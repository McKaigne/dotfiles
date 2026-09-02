{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # Requested Tools
      fd
      fastfetch
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
      symbola
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
    ];
  };
}
