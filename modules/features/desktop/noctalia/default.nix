{ self, inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [
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
