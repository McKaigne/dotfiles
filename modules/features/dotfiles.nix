
{ self, ... }: {
  flake.nixosModules.dotfiles = { lib, ... }:
    let
      dotfilesRootPath = ../../dotfiles;      # used only for reading the file list
      dotfilesRootStr = "/etc/nixos/dotfiles"; # used for the actual symlink target (no store copy)

      walk = rel:
        let
          entries = builtins.readDir (dotfilesRootPath + (if rel == "" then "" else "/${rel}"));
          go = name: type:
            let relPath = if rel == "" then name else "${rel}/${name}"; in
            if type == "directory" then walk relPath else [ relPath ];
        in
        lib.concatLists (lib.mapAttrsToList go entries);

      files = walk "";

      linkCmd = relPath: ''
        mkdir -p "/home/pollux/.config/$(dirname "${relPath}")"
        ln -sfn "${dotfilesRootStr}/${relPath}" "/home/pollux/.config/${relPath}"
      '';
    in
    {
      system.activationScripts.dotfilesLink.text =
        lib.concatStringsSep "\n" (map linkCmd files);
    };
}
