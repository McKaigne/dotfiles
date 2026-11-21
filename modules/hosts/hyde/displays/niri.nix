{
  flake.modules.homeManager."host-hyde-display-niri" = {
    programs.niri.settings.outputs."DP-1" = {
      mode = {
        width = 1920;
        height = 1080;
        refresh = 240.0;
      };
      scale = 1.0;
    };
  };
}
