{ inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
        pkgs.glib
        pkgs.dconf
        pkgs.gsettings-desktop-schemas
      ];

      # Immutable store-backed wallpapers directory
      environment.etc."wallpapers".source = ../../../../wallpapers;

      home-manager.users.${user} = {
        imports = [ inputs.noctalia.homeModules.default ];
        programs.noctalia.enable = true;

        xdg.configFile."noctalia/config.toml" = {
          source = ./noctalia.toml;
          force = true;
        };
      };
    };
}
