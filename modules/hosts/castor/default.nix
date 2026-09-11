{ self, inputs, ... }: {
  flake.nixosConfigurations.castor = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.workstation
      self.nixosModules.castorConfiguration
      self.nixosModules.castorHardware
    ];
  };
}