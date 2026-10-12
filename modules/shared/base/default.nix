{ self, inputs, ... }: {
  flake.nixosModules.baseWorkstation = { ... }: {
    imports = [
      # Shared primitives
      self.nixosModules.core
      self.nixosModules.users
      self.nixosModules.security
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.kanata

      # Desktop environment & shell
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.fuzzel
      self.nixosModules.fonts
      self.nixosModules.xdg
      self.nixosModules.noctaliaTheme

      # Terminal tools
      self.nixosModules.ghostty
      self.nixosModules.tmux
      self.nixosModules.zsh
      self.nixosModules.starship
      self.nixosModules.fetch

      # Editors & browsers
      self.nixosModules.helix
      self.nixosModules.floorp
      self.nixosModules.brave

      # Decoupled creative tools
      self.nixosModules.blender
      self.nixosModules.kdenlive
      self.nixosModules.krita
      self.nixosModules.obs

      # Decoupled document tools
      self.nixosModules.obsidian
      self.nixosModules.onlyoffice
      self.nixosModules.zathura

      # Decoupled developer tools
      self.nixosModules.git
      self.nixosModules.godot
      self.nixosModules.devTools

      # Decoupled media tools
      self.nixosModules.mpv
      self.nixosModules.imv
      self.nixosModules.parabolic

      # Network & security
      self.nixosModules.localsend
      self.nixosModules.bitwarden
    ];
  };
}
