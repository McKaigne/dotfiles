_: {
  flake.nixosModules.zathura =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      environment.systemPackages = [ pkgs.zathura ];

      home-manager.users.${user} = {
        programs.zathura = {
          enable = true;
          options = {
            default-bg = p.base;
            default-fg = p.text;
            statusbar-bg = p.mantle;
            statusbar-fg = p.text;
            inputbar-bg = p.crust;
            inputbar-fg = p.text;
            notification-error-bg = p.red;
            notification-error-fg = p.crust;
            notification-warning-bg = p.peach;
            notification-warning-fg = p.crust;
            highlight-color = "rgba(203, 166, 247, 0.5)";
            highlight-active-color = "rgba(243, 139, 168, 0.5)";
            recolor-lightcolor = p.base;
            recolor-darkcolor = p.text;
            recolor = "true";
            recolor-keephue = "true";
            selection-clipboard = "clipboard";
            window-title-basename = "true";
          };
        };
      };
    };
}
