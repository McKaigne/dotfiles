_: {
  flake.nixosModules.starship =
    { pkgs, ... }:
    {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
      };

      environment.sessionVariables = {
        STARSHIP_CONFIG = "/etc/starship.toml";
      };

      environment.etc."environment.d/10-starship.conf".text = "STARSHIP_CONFIG=/etc/starship.toml\n";
      environment.etc."starship.toml".source = ./starship.toml;
    };
}
