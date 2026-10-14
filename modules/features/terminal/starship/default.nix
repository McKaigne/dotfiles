{ self, inputs, ... }: {
  flake.nixosModules.starship =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
      };

      home-manager.users.${user} = {
        xdg.configFile."starship.toml" = {
          source = ./starship.toml;
          force = true;
        };
      };
    };
}
