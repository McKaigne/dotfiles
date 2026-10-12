{ self, inputs, ... }: {
  flake.nixosModules.starship = { pkgs, ... }: {
    programs.starship = {
      enable = true;
      package = pkgs.starship;
    };
    environment.sessionVariables = {
      STARSHIP_CONFIG = "/etc/starship.toml";
    };
    environment.etc."starship.toml".source = ./starship.toml;
  };
}
