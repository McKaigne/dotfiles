{
  flake.modules.homeManager.helium =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      widevine = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
      heliumProfileDir = "${config.xdg.configHome}/net.imput.helium/Default";
      heliumPreferences = "${heliumProfileDir}/Preferences";
      heliumSingletonLock = "${config.xdg.configHome}/net.imput.helium/SingletonLock";
    in
    {
      home.packages = [ pkgs.helium ];

      xdg.configFile."net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text =
        builtins.toJSON { Path = widevine; };

      home.activation.disableHeliumRoundedFrame =
        lib.hm.dag.entryAfter [ "writeBoundary" ]
          ''
            preferences=${lib.escapeShellArg heliumPreferences}
            profileDir=${lib.escapeShellArg heliumProfileDir}
            singletonLock=${lib.escapeShellArg heliumSingletonLock}

            if [ -n "''${DRY_RUN_CMD:-}" ]; then
              echo "Would disable Helium's rounded web-content frame"
            elif [ -e "$singletonLock" ] || [ -L "$singletonLock" ]; then
              echo "warning: Helium is running; close it and activate again to disable its rounded frame" >&2
            else
              ${pkgs.coreutils}/bin/mkdir -p "$profileDir"
              temporary="$(${pkgs.coreutils}/bin/mktemp "$profileDir/.Preferences.XXXXXX")"
              trap '${pkgs.coreutils}/bin/rm -f "$temporary"' EXIT

              if [ -f "$preferences" ]; then
                ${pkgs.jq}/bin/jq '.helium.browser.rounded_frame = false' "$preferences" > "$temporary"
                ${pkgs.coreutils}/bin/chmod --reference="$preferences" "$temporary"
              else
                ${pkgs.jq}/bin/jq -n '.helium.browser.rounded_frame = false' > "$temporary"
                ${pkgs.coreutils}/bin/chmod 600 "$temporary"
              fi

              if [ -f "$preferences" ] && ${pkgs.diffutils}/bin/cmp -s "$preferences" "$temporary"; then
                ${pkgs.coreutils}/bin/rm -f "$temporary"
              else
                ${pkgs.coreutils}/bin/mv "$temporary" "$preferences"
              fi
              trap - EXIT
            fi
          '';
    };
}
