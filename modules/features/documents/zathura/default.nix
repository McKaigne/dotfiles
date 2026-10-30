{ self, inputs, ... }: {
  flake.nixosModules.zathura =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.zathura ];

      home-manager.users.${user} = {
        programs.zathura = {
          enable = true;
          options = {
            selection-clipboard = "clipboard";
            window-title-basename = "true";
            recolor = "true";
            recolor-keephue = "true";
          };
        };
      };
    };
}
