
{ self, inputs, ... }: {
  flake.nixosModules.homeManager = { inputs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];

    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;

    home-manager.users.pollux = { lib, config, ... }:
      let
        dotfilesRootPath = ../../dotfiles;
        dotfilesRootStr = "/etc/nixos/dotfiles";

        walk = rel:
          let
            entries = builtins.readDir (dotfilesRootPath + (if rel == "" then "" else "/${rel}"));
            go = name: type:
              let relPath = if rel == "" then name else "${rel}/${name}"; in
              if type == "directory" then walk relPath else [ relPath ];
          in
          lib.concatLists (lib.mapAttrsToList go entries);

        files = walk "";

        toEntry = relPath: {
          name = relPath;
          value.source = config.lib.file.mkOutOfStoreSymlink "${dotfilesRootStr}/${relPath}";
        };
      in
      {
        home.stateVersion = "25.05";
        xdg.configFile = builtins.listToAttrs (map toEntry files);
      };
  };
}
