{ ... }: {
  imports = [
    ./nix.nix
    ./users.nix
    ./security.nix
    ./utilities.nix
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_user_instances" = 1024;
  };
}
