{ self, ... }: {
  flake.nixosModules.workstation = {
    imports = [
      self.nixosModules.user
      self.nixosModules.theme
      self.nixosModules.desktop

      self.nixosModules.emacs
      self.nixosModules.ghostty
      self.nixosModules.niri
      self.nixosModules.whichKey
      self.nixosModules.noctalia
      self.nixosModules.nushell
      self.nixosModules.helix
      self.nixosModules.tmux
      self.nixosModules.thunar
      self.nixosModules.yazi
      self.nixosModules.helium
      self.nixosModules.kanata
      self.nixosModules.fuzzel
      self.nixosModules.btop
      self.nixosModules.cava
      self.nixosModules.mpv
      self.nixosModules.viewers
    ];
  };
}