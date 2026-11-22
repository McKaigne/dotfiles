{
  nixos.base = {pkgs, ...}: {
    environment.localBinInPath = true;

    security.sudo.extraConfig = ''
      Defaults passwd_timeout=0
      Defaults timestamp_timeout=30
    '';

    hardware.keyboard.qmk.enable = true;

    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="369b", MODE="0660", GROUP="users", TAG+="uaccess"
    '';

    # Helix for root, sudoedit and anything outside a user session too
    # (NixOS would default to nano).
    environment.systemPackages = [pkgs.helix];
    environment.variables = {
      EDITOR = "hx";
      VISUAL = "hx";
      XCURSOR_SIZE = "24";
      QT_QPA_PLATFORM = "wayland";
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      BAT_THEME = "noctalia";

      FZF_DEFAULT_COMMAND = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      FZF_CTRL_T_COMMAND = "${pkgs.fd}/bin/fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
      FZF_CTRL_T_OPTS = "--preview '${pkgs.bat}/bin/bat -n --color=always --line-range :500 {}' --preview-window=right:60%:wrap";
      FZF_ALT_C_COMMAND = "${pkgs.fd}/bin/fd --type d --strip-cwd-prefix --hidden --follow --exclude .git";
      FZF_ALT_C_OPTS = "--preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always {} | head -200' --preview-window=right:60%:wrap";

      NNN_COLORS = "5423";
      NNN_FCOLORS = "030305020704060801060501";
    };
  };
}
