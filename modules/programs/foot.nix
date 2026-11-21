{
  flake.modules.homeManager.foot = {
    config,
    lib,
    pkgs,
    ...
  }: let
    footConfig = "${config.xdg.configHome}/foot/foot.ini";
    footTheme = "${config.xdg.configHome}/foot/themes/noctalia";
  in {
    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "Maple Mono NF:size=11";
          pad = "8x8";
          initial-color-theme = "dark";
          include = "~/.config/foot/themes/noctalia";
        };
        scrollback.lines = 10000;
        cursor.style = "block";
      };
    };

    xdg.configFile."foot/foot.ini".force = true;

    home.activation.makeFootConfigWritable =
      lib.hm.dag.entryAfter ["onFilesChange"]
      ''
        footConfig=${lib.escapeShellArg footConfig}
        footTheme=${lib.escapeShellArg footTheme}
        if [ -L "$footConfig" ]; then
          target="$(${pkgs.coreutils}/bin/readlink -f "$footConfig")"
          case "$target" in
            /nix/store/*)
              $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$footConfig"
              $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$footConfig"
              ;;
          esac
        fi
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$footTheme")"
        if [ ! -f "$footTheme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
          printf '[colors-dark]\nbackground=1e1e2e\nforeground=cdd6f4\n' > "$footTheme"
        fi
      '';
  };
}
