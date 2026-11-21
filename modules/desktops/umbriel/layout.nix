let
  style = import ../../appearance/_style.nix;
in {
  flake.modules.homeManager."desktop-umbriel" = {...}: {
    programs.umbriel.settings = {
      layout = {
        mode = "scrolling";
        gap = style.gap;
        extent_presets = [
          0.333
          0.5
          0.667
        ];
        scrolling = {
          default_extent_fraction = 0.5;
          # A lone window (or any strip narrower than the screen) sits centered.
          center_underfull_strip = true;
        };
        stacking.drop_zones = true;
      };

      workspaces.back_and_forth = true;
    };
  };
}
