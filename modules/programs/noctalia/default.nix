{ inputs, config, ... }:
{
  flake.modules.nixos.noctalia = {
    home-manager.sharedModules = [
      config.flake.modules.homeManager.noctalia
      config.flake.modules.homeManager.noctalia-sync
    ];
    nixpkgs.overlays = [
      (final: _: {
        noctalia = final.callPackage (inputs.noctalia.outPath + "/nix/package.nix") {
          rev = "local";
        };
      })
    ];
    environment.etc."wallpapers".source = ../../../wallpapers;
  };

  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.noctalia ];
      xdg.configFile."noctalia/palettes" = {
        source = ./palettes;
        recursive = true;
      };
    };

  flake.modules.homeManager.noctalia-sync = {
    imports = [ ./gui-sync.nix ];
  };
}
