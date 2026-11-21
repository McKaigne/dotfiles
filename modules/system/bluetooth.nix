{
  nixos.base = {pkgs, ...}: {
    hardware.bluetooth = {
      enable = true;
      settings.General.Experimental = true;
    };
    # Blueman manager for advanced pairing; Noctalia's panel stays the agent.
    services.blueman.enable = true;
    services.dbus = {
      enable = true;
      packages = [pkgs.bluez];
    };
    environment.systemPackages = [pkgs.bluez];
  };

  homeManager.base = {
    # Hide blueman-applet's autostart so it doesn't duplicate Noctalia's tray and pairing prompts.
    xdg.configFile."autostart/blueman.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Hidden=true
    '';
  };
}
