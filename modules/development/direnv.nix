{
  flake.modules.homeManager.development = {
    programs.direnv = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableGitIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
