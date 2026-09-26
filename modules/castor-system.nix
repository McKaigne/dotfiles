
{ self, inputs, ... }: {
  flake.nixosConfigurations.castor = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = builtins.attrValues self.nixosModules;
  };
}
