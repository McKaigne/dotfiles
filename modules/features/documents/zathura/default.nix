{ self, inputs, ... }: {
  flake.nixosModules.zathura =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.zathura ];

      home-manager.users.${user} = {
        xdg.configFile."zathura/zathurarc" = {
          text = ''
            set default-bg "#1e1e2e"
            set default-fg "#cdd6f4"
            set statusbar-bg "#181825"
            set statusbar-fg "#cdd6f4"
            set inputbar-bg "#11111b"
            set inputbar-fg "#cdd6f4"
            set notification-error-bg "#f38ba8"
            set notification-error-fg "#11111b"
            set notification-warning-bg "#fab387"
            set notification-warning-fg "#11111b"
            set highlight-color "rgba(203, 166, 247, 0.5)"
            set highlight-active-color "rgba(243, 139, 168, 0.5)"
            set recolor-lightcolor "#1e1e2e"
            set recolor-darkcolor "#cdd6f4"
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
