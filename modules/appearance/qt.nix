{config, ...}: {
  flake.modules.nixos.qt = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager.qt];
    qt = {
      enable = true;
      platformTheme = "qt5ct";
      style = "adwaita-dark";
    };
    environment.systemPackages = with pkgs; [
      kdePackages.qt6ct
      libsForQt5.qt5ct
    ];
  };

  flake.modules.homeManager.qt = {
    config,
    lib,
    pkgs,
    ...
  }: let
    qt5Color = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
    qt6Color = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
    mkQtConf = colorPath: ''
      [Appearance]
      color_scheme_path=${colorPath}
      custom_palette=true
      icon_theme=Noctalia-Gruvbox
      standard_dialogs=default
      style=Adwaita-Dark

      [Fonts]
      fixed="Maple Mono NF,10,-1,5,50,0,0,0,0,0"
      general="Maple Mono NF,10,-1,5,50,0,0,0,0,0"
    '';
  in {
    xdg.configFile = {
      "qt5ct/qt5ct.conf" = {
        text = mkQtConf qt5Color;
        force = true;
      };
      "qt6ct/qt6ct.conf" = {
        text = mkQtConf qt6Color;
        force = true;
      };
    };

    home.activation.makeQtConfigsWritable =
      lib.hm.dag.entryAfter ["onFilesChange"]
      ''
        for f in \
          ${lib.escapeShellArg "${config.xdg.configHome}/qt5ct/qt5ct.conf"} \
          ${lib.escapeShellArg "${config.xdg.configHome}/qt6ct/qt6ct.conf"}; do
          if [ -L "$f" ]; then
            target="$(${pkgs.coreutils}/bin/readlink -f "$f")"
            case "$target" in
              /nix/store/*)
                $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$f"
                $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$f"
                ;;
            esac
          fi
        done

        for d in \
          ${lib.escapeShellArg "${config.xdg.configHome}/qt5ct/colors"} \
          ${lib.escapeShellArg "${config.xdg.configHome}/qt6ct/colors"}; do
          $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$d"
        done
      '';
  };
}
