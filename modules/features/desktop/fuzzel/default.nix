_: {
  flake.nixosModules.fuzzel =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      inherit (config) theme;
    in
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      home-manager.users.${user} = {
        programs.fuzzel = {
          enable = true;
          settings = {
            main = {
              font = "${theme.fonts.sans.name}:size=11";
              prompt = "\"➜ \"";
              lines = 12;
              width = 35;
              horizontal-pad = 20;
              vertical-pad = 15;
              inner-pad = 10;
              prefer-no-csd = true;
            };
            border = {
              width = theme.borderWidth;
              inherit (theme) radius;
            };
          };
        };
      };
    };
}
