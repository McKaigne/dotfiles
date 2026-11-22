{
  flake.modules.homeManager."host-hyde-display-umbriel" = {
    programs.umbriel.settings.output."DP-1" = {
      mode = "1920x1080@240.000";
      position = [
        0
        0
      ];
      scale = 1.0;
      transform = "normal";
      vrr = "disabled";
      hdr = "auto";
      workspaces = 3;
    };
  };
}
