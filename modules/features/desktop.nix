{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, ... }: {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
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
