{
  flake.modules.homeManager."helium" = {
    pkgs,
    config,
    lib,
    ...
  }: let
    heliumUnwrapped = pkgs.helium-widevine;
    helium = heliumUnwrapped.overrideAttrs (oldAttrs: {
      postFixup =
        (oldAttrs.postFixup or "")
        + ''
          wrapProgram "$out/bin/helium" \
            --add-flags "--enable-features=HeliumMiddleClickAutoscroll" \
            --add-flags "--force-device-scale-factor=1.1"
        '';
    });
    widevine = "${pkgs.widevine-cdm}/share/google/chrome/WidevineCdm";
    heliumDesktop = ["helium.desktop"];
    heliumProfileDir = "${config.xdg.configHome}/net.imput.helium/Default";
    heliumPreferences = "${heliumProfileDir}/Preferences";
    heliumSingletonLock = "${config.xdg.configHome}/net.imput.helium/SingletonLock";

    # Noctalia renders the color into the cache; this copies it into the
    # policy file in place (the directory is root's) and has a running Helium
    # reload its policies, so the toolbar follows the wallpaper live.
    themePolicy = "/etc/chromium/policies/managed/helium-theme.json";
    applyTheme = pkgs.writeShellScript "helium-apply-theme" ''
      rendered="''${XDG_CACHE_HOME:-$HOME/.cache}/noctalia/helium-theme.json"
      policy=${lib.escapeShellArg themePolicy}
      [ -f "$rendered" ] && [ -w "$policy" ] || exit 0
      ${pkgs.diffutils}/bin/cmp -s "$rendered" "$policy" || cat "$rendered" > "$policy"
      if [ -L ${lib.escapeShellArg heliumSingletonLock} ]; then
        ${pkgs.coreutils}/bin/timeout --kill-after=1s 5s ${lib.getExe helium} \
          --refresh-platform-policy --no-startup-window >/dev/null 2>&1 || true
      fi
    '';
  in {
    home = {
      packages = [helium];
      # LibreWolf is the default browser; Helium stays available.
      sessionVariables.BROWSER = lib.mkDefault (lib.getExe helium);
    };

    xdg.configFile."noctalia/helium.toml".source = (pkgs.formats.toml {}).generate "helium-template.toml" {
      theme.templates.user.helium = {
        input_path = pkgs.writeText "helium-theme.json.in" ''
          { "BrowserThemeColor": "{{colors.surface.default.hex}}" }
        '';
        output_path = "$XDG_CACHE_HOME/noctalia/helium-theme.json";
        post_hook = "${applyTheme}";
      };
    };

    xdg.configFile."net.imput.helium/WidevineCdm/latest-component-updated-widevine-cdm".text =
      builtins.toJSON {Path = widevine;};

    # Helium exposes this as a normal profile preference rather than an enterprise
    # policy. Converge it during activation, but never rewrite Preferences while
    # the browser owns the profile.
    home.activation.disableHeliumRoundedFrame = lib.hm.dag.entryAfter ["writeBoundary"] ''
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

    xdg.mimeApps = {
      enable = true;
      defaultApplicationPackages = [helium];

      defaultApplications = {
        "application/vnd.mozilla.xul+xml" = heliumDesktop;
        "x-scheme-handler/about" = heliumDesktop;
        "x-scheme-handler/unknown" = heliumDesktop;
      };
    };
  };
}
