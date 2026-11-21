{
  flake.modules.homeManager.desktop-niri = {
    programs.niri.settings.animations = {
      workspace-switch.kind.spring = {
        damping-ratio = 1.0;
        stiffness = 1000;
        epsilon = 0.0001;
      };
      window-open.kind.easing = {
        duration-ms = 150;
        curve = "ease-out-quad";
      };
      window-close.kind.easing = {
        duration-ms = 150;
        curve = "ease-out-cubic";
      };
      horizontal-view-movement.kind.easing = {
        duration-ms = 140;
        curve = "ease-out-quad";
      };
      window-movement.kind.easing = {
        duration-ms = 140;
        curve = "ease-out-quad";
      };
      window-resize.kind.easing = {
        duration-ms = 140;
        curve = "ease-out-quad";
      };
      config-notification-open-close.kind.spring = {
        damping-ratio = 0.6;
        stiffness = 1000;
        epsilon = 0.001;
      };
      screenshot-ui-open.kind.easing = {
        duration-ms = 200;
        curve = "ease-out-quad";
      };
      overview-open-close.kind.easing = {
        duration-ms = 150;
        curve = "ease-out-quad";
      };
    };
  };
}
