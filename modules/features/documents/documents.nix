{ self, inputs, ... }: {
  flake.nixosModules.documents = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = with pkgs; [
      obsidian
      onlyoffice-desktopeditors
      zathura
    ];

    home-manager.users.${user} = {
      xdg.configFile."zathura/zathurarc".text = ''
        include noctaliarc
        set selection-clipboard clipboard
        set window-title-basename true
      '';
    };
  };
}
