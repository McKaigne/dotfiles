{
  description = "Castor & Hyde Workstations - Dendritic Architecture";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    noctalia.url = "github:noctalia-dev/noctalia";
    fetch = {
      url = "github:areofyl/fetch";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghgrab = {
      url = "github:abhixdd/ghgrab";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules);
}
