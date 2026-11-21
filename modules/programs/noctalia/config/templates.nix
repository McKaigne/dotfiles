{
  flake.modules.homeManager.noctalia = {pkgs, ...}: let
    reloadZathura = pkgs.writeShellScript "reload-zathura" ''
      for dest in $(${pkgs.dbus}/bin/dbus-send --session --dest=org.freedesktop.DBus --type=method_call --print-reply /org/freedesktop/DBus org.freedesktop.DBus.ListNames 2>/dev/null | ${pkgs.gnugrep}/bin/grep -o 'org\.pwmt\.zathura\.PID-[0-9]*' || true); do
        ${pkgs.dbus}/bin/dbus-send --session --dest="$dest" --type=method_call /org/pwmt/zathura org.pwmt.zathura.ExecuteCommand string:source >/dev/null 2>&1 || true
      done
    '';
  in {
    xdg.configFile."noctalia/70-templates.toml".source =
      (pkgs.formats.toml {}).generate "70-templates.toml"
      {
        theme.templates.user = {
          helix = {
            input_path = "${../templates/helix.toml}";
            output_path = "$XDG_CONFIG_HOME/helix/themes/noctalia.toml";
            post_hook = "pkill -USR1 hx >/dev/null 2>&1 || true";
          };
          fuzzel = {
            input_path = "${../templates/fuzzel.ini}";
            output_path = "$XDG_CONFIG_HOME/fuzzel/noctalia.ini";
          };
          zathura = {
            input_path = "${../templates/zathura}";
            output_path = "$XDG_CONFIG_HOME/zathura/noctalia";
            post_hook = "${reloadZathura}";
          };
        };
      };
  };
}
