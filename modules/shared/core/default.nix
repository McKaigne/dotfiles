{ self, inputs, ... }: {
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      nixpkgs.config.allowUnfree = true;
      i18n.defaultLocale = "en_US.UTF-8";

      nix.settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];
        warn-dirty = false;
        auto-optimise-store = true;
        max-jobs = "auto";
        cores = 0;
        substituters = [
          "https://cache.nixos.org"
          "https://devenv.cachix.org"
          "https://noctalia.cachix.org"
        ];
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        ];
      };

      systemd.tmpfiles.rules = [
        "d /etc/nixos 0775 ${user} wheel -"
        "z /etc/nixos 0775 ${user} wheel -"
      ];

      boot.kernel.sysctl = {
        "fs.inotify.max_user_watches" = 1048576;
        "fs.inotify.max_user_instances" = 1024;
      };

      security.sudo.extraConfig = ''
        Defaults passwd_timeout=0
        Defaults timestamp_timeout=30
      '';

      environment.localBinInPath = true;

      programs.nix-ld = {
        enable = true;
        libraries = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          openssl
          curl
          glibc
        ];
      };

      hardware.keyboard.qmk.enable = true;

      services.udev.extraRules = ''
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", ATTRS{idProduct}=="0051", MODE="0660", GROUP="users", TAG+="uaccess"
        KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", MODE="0660", GROUP="users", TAG+="uaccess"
      '';

      environment.sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
        BAT_THEME = "Catppuccin Mocha";
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
        nnn
        wtype
        aria2
        p7zip
        unrar
        rsync
        direnv
        devenv
        nvd
        nix-output-monitor
        wl-clipboard
      ];
    };
}
