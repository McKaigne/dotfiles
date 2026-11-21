{
  flake.modules.homeManager.nitch =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.nitch ];
    };
}
