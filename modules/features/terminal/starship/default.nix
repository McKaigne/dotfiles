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

      environment.sessionVariables = {
        STARSHIP_CONFIG = "/etc/starship.toml";
      };

      environment.etc."environment.d/10-starship.conf".text = "STARSHIP_CONFIG=/etc/starship.toml\n";
      environment.etc."starship.toml".source = "${pkgs.starship}/share/starship/presets/jetpack.toml";

      home-manager.users.${user} = {
        xdg.configFile."starship.toml" = {
          source = "${pkgs.starship}/share/starship/presets/jetpack.toml";
          force = true;
        };
      };
    };
}
