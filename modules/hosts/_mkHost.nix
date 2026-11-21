# Builds one host for its active desktop. Ignored by import-tree (leading _).
{
  inputs,
  m,
}: name: settings:
inputs.nixpkgs.lib.nixosSystem {
  modules = [
    m.nixos.host-common
    m.nixos."host-${name}"
    m.nixos."desktop-${settings.desktop}"
    m.nixos.noctalia-greeter
    {workstation = settings;}
  ];
}
