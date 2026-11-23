{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.zathura = {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.zathura];
  };

  flake.modules.homeManager.zathura = {
    config,
    lib,
    pkgs,
    ...
  }: let
    zathuraTheme = "${config.xdg.configHome}/zathura/noctalia";
  in {
    programs.zathura = {
      enable = true;
      options = {
        font = "Maple Mono NF 10";
        recolor = "true";
        recolor-keephue = "true";
        # Recolored pages take the glass background from the theme; pictures
        # keep their real colors and stay solid.
        recolor-reverse-video = "true";
        selection-clipboard = "clipboard";
        window-title-basename = "true";
      };
      extraConfig = ''
        include noctalia
      '';
    };

    home.activation.seedZathuraTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      theme=${lib.escapeShellArg zathuraTheme}
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$theme")"
      if [ ! -f "$theme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
        printf 'set default-bg "#1e1e2e"\nset default-fg "#cdd6f4"\n' > "$theme"
      fi
    '';
  };
}
