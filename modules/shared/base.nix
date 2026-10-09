{ self, inputs, ... }: {
  flake.nixosModules.baseWorkstation = { ... }: {
    imports = [
      self.nixosModules.core
      self.nixosModules.users
      self.nixosModules.security
      self.nixosModules.audio
      self.nixosModules.bluetooth
      self.nixosModules.kanata
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.fuzzel
      self.nixosModules.noctaliaTheme
      self.nixosModules.fonts
      self.nixosModules.xdg
      self.nixosModules.ghostty
      self.nixosModules.zellij
      self.nixosModules.fish
      self.nixosModules.emacs
      self.nixosModules.helix
      self.nixosModules.floorp
      self.nixosModules.brave
      self.nixosModules.cliamp
      self.nixosModules.media
      self.nixosModules.documents
      self.nixosModules.creative
      self.nixosModules.dev
      self.nixosModules.network
      self.nixosModules.bitwarden
    ];
  };
}
