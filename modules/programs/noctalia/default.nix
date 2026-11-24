{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos."noctalia" = {
    home-manager.sharedModules = [config.flake.modules.homeManager."noctalia"];
    # Built against this system's nixpkgs, not the flake's own: Noctalia loads
    # the system's PAM modules (lock screen) and graphics driver at runtime, and
    # they need the same glibc. That rules out noctalia.cachix.org's build.
    nixpkgs.overlays = [
      (final: _: {
        noctalia = final.callPackage (inputs.noctalia.outPath + "/nix/package.nix") {rev = "local";};
      })
    ];
  };
  flake.modules.homeManager.noctalia = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.noctalia];

    # The settings window saves its overrides to settings.toml, which Noctalia
    # writes through a symlink. Point it into this repo: `git diff` shows what
    # changed in the window, commit to keep it, `git checkout` to drop it.
    # Settled values are better moved into their module and deleted here.
    xdg.stateFile."noctalia/settings.toml".source =
      config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/programs/noctalia/config/gui.toml";
    xdg.configFile = {
      "noctalia/palettes" = {
        source = ./palettes;
        recursive = true;
      };
    };
  };
}
