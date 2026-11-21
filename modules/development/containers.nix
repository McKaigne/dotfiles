{
  flake.modules.nixos.containers =
    { config, pkgs, ... }:
    {
      virtualisation.podman = {
        enable = true;
        dockerCompat = true;
        dockerSocket.enable = true;
        defaultNetwork.settings.dns_enabled = true;
      };

      users.users.${config.workstation.username}.extraGroups = [ "podman" ];

      environment.systemPackages = [ pkgs.podman-compose ];
    };
}
