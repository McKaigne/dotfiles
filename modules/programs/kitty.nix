{
  flake.modules.homeManager.kitty =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      kittyConfig = "${config.xdg.configHome}/kitty/kitty.conf";
      kittyTheme = "${config.xdg.configHome}/kitty/themes/noctalia.conf";
    in
    {
      programs.kitty = {
        enable = true;

        font = {
          name = "GaramontoCode Nerd Font";
          size = 12;
        };

        settings = {
          disable_ligatures = "always";
          hide_window_decorations = true;
          background_opacity = "1.0";
          include = "themes/noctalia.conf";
        };
      };

      xdg.configFile."kitty/kitty.conf".force = true;

      home.activation.makeKittyConfigWritable =
        lib.hm.dag.entryAfter [ "onFilesChange" ]
          ''
            kittyConfig=${lib.escapeShellArg kittyConfig}
            kittyTheme=${lib.escapeShellArg kittyTheme}
            if [ -L "$kittyConfig" ]; then
              target="$(${pkgs.coreutils}/bin/readlink -f "$kittyConfig")"
              case "$target" in
                /nix/store/*)
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$kittyConfig"
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$kittyConfig"
                  ;;
              esac
            fi
            $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$kittyTheme")"
            if [ ! -f "$kittyTheme" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
              printf 'background #1e1e2e\nforeground #cdd6f4\n' > "$kittyTheme"
            fi
          '';
    };
}
