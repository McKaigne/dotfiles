{
  nixos.base = {
    networking.networkmanager.enable = true;
    services.fstrim.enable = true;
  };
}
