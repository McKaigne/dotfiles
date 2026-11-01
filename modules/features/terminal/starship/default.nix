_: {
  flake.nixosModules.starship =
    { pkgs, ... }:
    {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        presets = [ "jetpack" ];
      };

      environment.sessionVariables = {
        STARSHIP_CONFIG = "/etc/starship.toml";
      };

      environment.etc."environment.d/10-starship.conf".text = "STARSHIP_CONFIG=/etc/starship.toml\n";
      environment.etc."starship.toml".source = "${pkgs.starship}/share/starship/presets/jetpack.toml";
    };
}
