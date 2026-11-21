{ config, ... }:
let
  flakeConfig = config;
in
{
  flake.modules.nixos.zathura =
    { pkgs, ... }:
    {
      home-manager.sharedModules = [ flakeConfig.flake.modules.homeManager.zathura ];
      environment.systemPackages = [ pkgs.zathura ];
    };

  flake.modules.homeManager.zathura =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      zathuraTheme = "${config.xdg.configHome}/zathura/noctalia";
    in
    {
      programs.zathura = {
        enable = true;
        options = {
          font = "Maple Mono NF 10";
          recolor = "true";
          recolor-keephue = "true";
          selection-clipboard = "clipboard";
          window-title-basename = "true";
        };
        extraConfig = ''
          include noctalia
        '';
      };

      home.activation.seedZathuraTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        theme=${lib.escapeShellArg zathuraTheme}
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$theme")"
        if [ ! -f "$theme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
          printf 'set default-bg "#1e1e2e"\nset default-fg "#cdd6f4"\n' > "$theme"
        fi
      '';
    };
}
