{
  # `nsync`: review Noctalia settings-window changes and keep the ones you
  # want in /etc/nixos (see nsync.sh). Hyde only.
  flake.modules.homeManager.noctalia-gui-sync = {pkgs, ...}: {
    home.packages = [
      (pkgs.writeShellApplication {
        name = "nsync";
        runtimeInputs = [pkgs.remarshal pkgs.jq pkgs.coreutils];
        text = builtins.readFile ./nsync.sh;
      })
    ];
  };
}
