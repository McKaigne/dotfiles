{ self, inputs, ... }: {
  flake.nixosConfigurations.castor = inputs.nixpkgs.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [
      self.nixosModules.castorConfiguration
      self.nixosModules.castorHardware
    ] ++ (builtins.attrValues (builtins.removeAttrs self.nixosModules [
      "castorConfiguration"
      "castorHardware"
      "workstation"
      "niri"
      "helium"
      "cliamp"
      "emacs"
      "tmux"
      "kanata"
      "desktop"
    ]));
  };
}