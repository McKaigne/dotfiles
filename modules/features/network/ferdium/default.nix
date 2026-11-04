_: {
  flake.nixosModules.ferdium =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.ferdium ];

      home-manager.users.${user} =
        { lib, ... }:
        {
          home.activation.ferdiumAutoHideMenuBar =
            lib.hm.dag.entryAfter [ "writeBoundary" ]
              ''
                settingsFile="$HOME/.config/Ferdium/config/settings.json"
                if [ -f "$settingsFile" ]; then
                  ${pkgs.jq}/bin/jq '.autohideMenuBar = true' "$settingsFile"                   > "$settingsFile.tmp" && mv "$settingsFile.tmp" "$settingsFile"
                else
                  mkdir -p "$HOME/.config/Ferdium/config"
                  echo '{"autohideMenuBar": true}' > "$settingsFile"
                fi
              '';

          xdg.configFile."Ferdium/config/custom.css" = {
            text = ''
              .titlebar,
              #titlebar,
              .window-controls,
              .window-controls-container,
              .top-bar,
              [class*="titlebar"],
              [class*="window-controls"],
              [class*="Titlebar"],
              [class*="WindowControls"] {
                display: none !important;
                height: 0 !important;
                visibility: hidden !important;
              }
            '';
            force = true;
          };

          xdg.configFile."Ferdium/custom.css" = {
            text = ''
              .titlebar,
              #titlebar,
              .window-controls,
              .window-controls-container,
              .top-bar,
              [class*="titlebar"],
              [class*="window-controls"],
              [class*="Titlebar"],
              [class*="WindowControls"] {
                display: none !important;
                height: 0 !important;
                visibility: hidden !important;
              }
            '';
            force = true;
          };
        };
    };
}
