{ self, inputs, ... }: {
  flake.nixosModules.containers = { config, pkgs, ... }: {
    virtualisation.podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    # Automatically attach user to podman group only when this module is imported
    users.users.${config.mainUser}.extraGroups = [ "podman" ];

    environment.systemPackages = with pkgs; [
      podman-compose
    ];
  };
}
