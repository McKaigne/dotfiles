{
  nixos.base = {
    config,
    pkgs,
    ...
  }: let
    user = config.workstation.username;
  in {
    systemd.services.nix-daemon.path = [pkgs.git];

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
        "https://noctalia.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };

    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.permittedInsecurePackages = [
      "pnpm-10.29.2"
    ];

    programs.nh = {
      enable = true;
      flake = "/etc/nixos";
      clean = {
        enable = true;
        dates = "weekly";
        extraArgs = "--keep-since 14d";
      };
    };

    programs.nix-ld.enable = true;

    systemd.tmpfiles.rules = [
      "d /etc/nixos 0775 ${user} wheel -"
      "z /etc/nixos 0775 ${user} wheel -"
    ];
  };
}
