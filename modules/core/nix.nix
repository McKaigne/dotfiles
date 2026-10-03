{ pkgs, ... }: {
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
    auto-optimise-store = true;
    max-jobs = "auto";
    cores = 0;
    keep-outputs = true;
    keep-derivations = true;
    substituters = [
      "https://cache.nixos.org"
      "https://devenv.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
    ];
  };

  environment.systemPackages = with pkgs; [
    direnv
    devenv
    nvd
    nix-output-monitor
    nix-tree
    manix
    nix-init
    nix-melt
  ];
}
