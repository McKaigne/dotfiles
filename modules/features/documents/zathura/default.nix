{ self, inputs, ... }: {
  flake.nixosModules.zathura =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
    in
    {
      environment.systemPackages = [ pkgs.zathura ];

      home-manager.users.${user} = {
        xdg.configFile."zathura/zathurarc" = {
          text = ''
            set default-bg "${p.base}"
            set default-fg "${p.text}"
            set statusbar-bg "${p.mantle}"
            set statusbar-fg "${p.text}"
            set inputbar-bg "${p.crust}"
            set inputbar-fg "${p.text}"
            set notification-error-bg "${p.red}"
            set notification-error-fg "${p.crust}"
            set notification-warning-bg "${p.peach}"
            set notification-warning-fg "${p.crust}"
            set highlight-color "rgba(203, 166, 247, 0.5)"
            set highlight-active-color "rgba(243, 139, 168, 0.5)"
            set recolor-lightcolor "${p.base}"
            set recolor-darkcolor "${p.text}"
            set recolor "true"
            set recolor-keephue "true"
            set selection-clipboard clipboard
            set window-title-basename true
          '';
          force = true;
        };
      };
    };
}
