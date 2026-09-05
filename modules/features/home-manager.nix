
{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { inputs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.pollux = { pkgs, ... }: {
      home.stateVersion = "25.05";

      xdg.configFile."starship/starship.toml".source = ./nushell/starship.toml;
      xdg.configFile."fuzzel/fuzzel.ini".source = ./fuzzel/fuzzel.ini;
      xdg.configFile."cava/config".source = ./cava/config;

      # Per-app xdg.configFile entries get added here as we migrate
      # each ~/.config/<app> dir.
    };
  };
}
