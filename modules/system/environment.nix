{
  nixos.base = {
    environment.localBinInPath = true;

    security.sudo.extraConfig = ''
      Defaults passwd_timeout=0
      Defaults timestamp_timeout=30
    '';

    hardware.keyboard.qmk.enable = true;

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", MODE="0660", GROUP="users", TAG+="uaccess"
    '';

    # The user session's editor is Emacs (users/workstation); root and anything
    # outside a session keep NixOS's nano.
    environment.variables = {
      XCURSOR_SIZE = "24";
      QT_QPA_PLATFORM = "wayland";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      BAT_THEME = "noctalia";

      NNN_COLORS = "5423";
      NNN_FCOLORS = "030305020704060801060501";
    };
  };
}
