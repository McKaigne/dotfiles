# Programming, for hosts that import `development`: toolchains and language
# servers (languages.nix), C/C++ with ccache (cpp.nix), direnv and CLI
# tools. Their Home Manager half is the `development` module the files
# beside this one add to. Android and Haskell are separate features
# (android.nix, haskell.nix), being far larger than the rest.
{config, ...}: {
  flake.modules.nixos.development = {
    home-manager.sharedModules = [config.flake.modules.homeManager.development];
  };
}
