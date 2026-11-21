{
  flake.modules.nixos.krita = {pkgs, ...}: {
    environment.systemPackages = [pkgs.krita];
  };
}
