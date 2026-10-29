{ self, inputs, ... }: {
  flake.nixosModules.baseWorkstation = { ... }: {
    imports = [
      self.nixosModules.palette
      self.nixosModules.core
      self.nixosModules.users
      self.nixosModules.security
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.kanata

      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.fuzzel
      self.nixosModules.fonts
      self.nixosModules.xdg
      self.nixosModules.catppuccinTheme

      # Shell & Multiplexer Parity Layer
      self.nixosModules.foot
      self.nixosModules.ghostty
      self.nixosModules.tmux
      self.nixosModules.bash
      self.nixosModules.zsh
      self.nixosModules.fish
      self.nixosModules.nushell
      self.nixosModules.xonsh
      self.nixosModules.starship
      self.nixosModules.fastfetch

      # Editors
      self.nixosModules.nixvim

      # Browsers
      self.nixosModules.librewolf
      self.nixosModules.brave

      # Mobile-friendly sketching & documents
      self.nixosModules.krita
      self.nixosModules.obsidian
      self.nixosModules.onlyoffice
      self.nixosModules.zathura

      # Core developer tools & media consumption
      self.nixosModules.git
      self.nixosModules.devTools
      self.nixosModules.mpv
      self.nixosModules.imv
      self.nixosModules.parabolic

      # Network & security
      self.nixosModules.localsend
      self.nixosModules.ferdium
      self.nixosModules.bitwarden
    ];
  };
}
