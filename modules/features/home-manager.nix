
{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { inputs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.pollux = { pkgs, ... }: {
      home.stateVersion = "25.05";

      # Per-app xdg.configFile entries get added here (or split into
      # their own modules) as we migrate each ~/.config/<app> dir.
    };
  };
}
