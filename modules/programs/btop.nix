{
  flake.modules.homeManager.btop =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      btopConfig = "${config.xdg.configHome}/btop/btop.conf";
      btopTheme = "${config.xdg.configHome}/btop/themes/noctalia.theme";
    in
    {
      programs.btop = {
        enable = true;
        settings = {
          color_theme = "noctalia";
          theme_background = true;
          truecolor = true;
          vim_keys = true;
          rounded_corners = false;
          graph_symbol = "braille";
        };
      };

      xdg.configFile."btop/btop.conf".force = true;

      home.activation.makeBtopConfigWritable =
        lib.hm.dag.entryAfter [ "onFilesChange" ]
          ''
            btopConfig=${lib.escapeShellArg btopConfig}
            btopTheme=${lib.escapeShellArg btopTheme}
            if [ -L "$btopConfig" ]; then
              target="$(${pkgs.coreutils}/bin/readlink -f "$btopConfig")"
              case "$target" in
                /nix/store/*)
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$btopConfig"
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$btopConfig"
                  ;;
              esac
            fi
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$btopTheme")"
            if [ ! -f "$btopTheme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
              printf 'theme[main_bg]="#1e1e2e"\ntheme[main_fg]="#cdd6f4"\n' > "$btopTheme"
            fi
          '';
    };
}
