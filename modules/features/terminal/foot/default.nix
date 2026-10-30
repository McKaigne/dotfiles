{ self, inputs, ... }: {
  flake.nixosModules.foot =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      theme = config.theme;
    in
    {
      environment.systemPackages = [ pkgs.foot ];

      home-manager.users.${user} = {
        programs.foot = {
          enable = true;
          server.enable = true;
          settings = {
            main = {
              term = "foot";
              shell = "${pkgs.fish}/bin/fish";
              font = "${theme.fonts.mono.name}:pixelsize=26";
              line-height = "26px";
              dpi-aware = "no";
              pad = "14x14";
            };
            colors = {
              alpha = theme.opacity;
            };
          };
        };
      };
    };
}
