{ self, inputs, ... }: {
  flake.nixosModules.network = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.localsend ];
    networking.firewall = {
      allowedTCPPorts = [ 53317 ];
      allowedUDPPorts = [ 53317 ];
    };
  };

  flake.nixosModules.bitwarden = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.bitwarden-desktop ];
  };
}
