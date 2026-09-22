{ self, ... }: {
  flake.nixosModules.workstation = {
    imports = [
      self.nixosModules.user
      self.nixosModules.theme
      self.nixosModules.desktop

      self.nixosModules.ghostty
      self.nixosModules.niri
      self.nixosModules.noctalia
      self.nixosModules.nushell
      self.nixosModules.helix
      self.nixosModules.tmux
      self.nixosModules.superfile
      self.nixosModules.helium
      self.nixosModules.kanata
      self.nixosModules.fuzzel
      self.nixosModules.btop
      self.nixosModules.cava
      self.nixosModules.mpv
      self.nixosModules.viewers
      self.nixosModules.zed
      self.nixosModules.emacs
      self.nixosModules.easyeffects
      self.nixosModules.cliamp
      self.nixosModules.endcord
    ];
  };
}