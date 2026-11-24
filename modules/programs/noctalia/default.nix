{
  inputs,
  config,
  ...
}: {
  flake.modules.nixos."noctalia" = {
    home-manager.sharedModules = [config.flake.modules.homeManager."noctalia"];
    # The flake's own build, against its own nixpkgs (flake.nix), so it comes
    # from noctalia.cachix.org instead of compiling here.
    nixpkgs.overlays = [
      (final: _: {
        noctalia = inputs.noctalia.packages.${final.stdenv.hostPlatform.system}.default;
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
