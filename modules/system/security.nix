{
  nixos.base =
    { pkgs, ... }:
    {
      security.polkit = {
        enable = true;
        enablePkexecWrapper = true;
      };
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.greetd.enableGnomeKeyring = true;
      services.accounts-daemon.enable = true;
      hardware.enableRedistributableFirmware = true;

      environment.systemPackages = with pkgs; [
        gnome-keyring
        libsecret
        sops
        age
        ssh-to-age
        xwayland
      ];
    };
}
