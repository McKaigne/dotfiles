# Haskell: GHC, Cabal, the language server and Ormolu (Emacs formats with
# it). Its own feature, since haskell-language-server alone is ~7 GiB.
{config, ...}: {
  flake.modules.nixos.haskell = {
    home-manager.sharedModules = [config.flake.modules.homeManager.haskell];
  };
  flake.modules.homeManager.haskell = {pkgs, ...}: {
    home.packages = with pkgs; [
      ghc
      cabal-install
      haskell-language-server
      ormolu
    ];
  };
}
