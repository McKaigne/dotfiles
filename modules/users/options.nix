{
  imports = [ ./_options.nix ];
  flake.modules.generic.workstation-options = ./_options.nix;
}
