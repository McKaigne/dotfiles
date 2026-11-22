# Settings kept from the Noctalia settings window with `nsync keep`, stored in
# gui.json. They load last and win over the other Noctalia modules, so once a
# setting is settled, move it into its proper module and delete it here.
{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/99-gui.toml".source =
      (pkgs.formats.toml {}).generate "99-gui.toml"
      (builtins.fromJSON (builtins.readFile ./gui.json));
  };
}
