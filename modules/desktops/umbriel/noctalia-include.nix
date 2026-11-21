{
  flake.modules.homeManager."desktop-umbriel" =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      umbrielConfig = "${config.xdg.configHome}/umbriel/config.toml";
    in
    {
      programs.umbriel.settings.include.optional.files = [
        "bibata-cursor.toml"
        "noctalia.toml"
      ];

      xdg.configFile."umbriel/config.toml".force = true;

      home.activation.makeUmbrielConfigWritable =
        lib.hm.dag.entryAfter [ "onFilesChange" ]
          ''
            umbrielConfig=${lib.escapeShellArg umbrielConfig}
            if [ -L "$umbrielConfig" ]; then
              target="$(${pkgs.coreutils}/bin/readlink -f "$umbrielConfig")"
              case "$target" in
                /nix/store/*)
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp --remove-destination "$target" "$umbrielConfig"
                  $DRY_RUN_CMD ${pkgs.coreutils}/bin/chmod u+w "$umbrielConfig"
                  ;;
              esac
            fi
          '';
    };
}
