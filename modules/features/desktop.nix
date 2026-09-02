{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      git
      ghostty
      foot
      yazi       # Terminal File Manager
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      btop
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
