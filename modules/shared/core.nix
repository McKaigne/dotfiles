{ self, inputs, ... }: {
  flake.nixosModules.core = { config, pkgs, lib, ... }: {
    nixpkgs.config.allowUnfree = true;

    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
      max-jobs = "auto";
      cores = 0;
      substituters = [
        "https://cache.nixos.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    systemd.tmpfiles.rules = [
      "d /etc/nixos 0775 root wheel -"
      "Z /etc/nixos 0775 root wheel -"
      "d /etc/nixos/wallpapers 0775 root wheel -"
    ];

    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = 1048576;
      "fs.inotify.max_user_instances" = 1024;
    };

    security.sudo.extraConfig = ''
      Defaults passwd_timeout=0
      Defaults timestamp_timeout=30
    '';

    programs.nix-ld.enable = true;

    environment.sessionVariables = {
      EDITOR = "hx";
      VISUAL = "hx";
    };

    environment.systemPackages = with pkgs; [
      git
      delta
      lazygit
      gh
      tree
      btop
      bat
      eza
      dust
      gdu
      procs
      ripgrep
      fd
      findutils
      jq
      jnv
      sd
      xh
      curl
      yazi
      aria2
      p7zip
      unrar
      rsync
      direnv
      devenv
      nvd
      nix-output-monitor
    ];
  };
}
