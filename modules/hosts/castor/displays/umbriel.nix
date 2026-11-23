{
  flake.modules.homeManager."host-castor-display-umbriel" = {
    programs.umbriel.settings.output."eDP-1" = {
      position = [
        0
        0
      ];
      scale = 1.0;
      transform = "normal";
      vrr = "disabled";
      hdr = "auto";
      workspaces = 6;
    };
  };
}
