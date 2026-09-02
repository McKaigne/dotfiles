{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      # 3D fetch tool only
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
