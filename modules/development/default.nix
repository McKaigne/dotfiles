# Programming, for hosts that import `development`: toolchains and language
# servers (languages.nix), C/C++ with ccache (cpp.nix), Android for Flutter
# and Kotlin (android.nix), direnv and CLI tools. Their Home Manager half is
# the `development` module the files beside this one add to.
{config, ...}: {
  flake.modules.nixos.development = {
    home-manager.sharedModules = [config.flake.modules.homeManager.development];
  };
}
