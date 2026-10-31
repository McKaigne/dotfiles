{ self, ... }: {
  flake.nixosModules.baseWorkstation = { config, lib, ... }: {
    assertions = [
      {
        assertion = (config.swapDevices == [ ]) -> (
          config.boot.kernel.sysctl."vm.swappiness" or 0 == 180 &&
          config.boot.kernel.sysctl."vm.watermark_scale_factor" or 0 == 125 &&
          config.boot.kernel.sysctl."vm.page-cluster" or (-1) == 0
        );
        message = "Pure ZRAM hosts must set vm.swappiness = 180, vm.watermark_scale_factor = 125, and vm.page-cluster = 0 to prevent cache thrashing.";
      }
      {
        assertion = let
            niriConfig = config.home-manager.users.${config.mainUser}.xdg.configFile."niri/config.kdl".text or "";
          in
          !lib.hasInfix "xray true" niriConfig;
        message = "Niri window rules must keep xray false to ensure floating surfaces do not hide windows beneath them.";
      }
      {
        assertion = let
            noctaliaConfig = builtins.readFile ../../features/desktop/noctalia/noctalia.toml;
          in
          lib.hasInfix "enable_builtin_templates = false" noctaliaConfig &&
          lib.hasInfix "enable_community_templates = false" noctaliaConfig;
        message = "Noctalia templates must remain disabled to prevent store symlink clobbering and EROFS errors.";
      }
    ];

    imports = [
      self.nixosModules.hostBase
      self.nixosModules.palette
      self.nixosModules.core
      self.nixosModules.users
      self.nixosModules.security
      self.nixosModules.deploy
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
      self.nixosModules.zellij
      self.nixosModules.bash
      self.nixosModules.zsh
      self.nixosModules.fish
      self.nixosModules.starship
      self.nixosModules.nitch
      self.nixosModules.nvchad

      # Editors
      self.nixosModules.helix

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
