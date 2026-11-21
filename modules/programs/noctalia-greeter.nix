{inputs, ...}: {
  flake.modules.nixos."noctalia-greeter" = {
    pkgs,
    config,
    lib,
    ...
  }: let
    desktops = import ../desktops/_metadata.nix;
    greeterSession = desktops.greeterSession config.workstation.desktop;

    noctaliaGreeter = pkgs.noctalia-greeter.overrideAttrs (old: {
      src = lib.cleanSourceWith {
        inherit (old) src;
        filter = path: _type: let
          base = baseNameOf path;
        in
          base != "build" && base != "build-release" && base != "build-asan";
      };
    });

    greeterSettings = {
      greeter_user = "greeter";
      session = {
        default = greeterSession;
        last = greeterSession;
      };
      user = {
        default = config.workstation.username;
      };
      appearance = {
        scheme = "Synced";
        password_style = "random";
        font_family = (import ../appearance/_style.nix).font;
      };
      cursor = {
        theme = config.workstation.cursor.theme;
        path = config.workstation.cursor.package;
        size = 24;
      };
      keyboard = {
        layout = "us";
      };
    };
  in {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
      {
        services.displayManager.noctalia-greeter = {
          enable = true;
          package = noctaliaGreeter;
          passwordless-sync-users = [config.workstation.username];
          greeter-args = "";
          settings = greeterSettings;
        };

        # The module owns greeter.toml; only the synchronized UI state is mutable.
        systemd.tmpfiles.settings."10-noctalia-greeter"."/var/lib/noctalia-greeter/sync.toml".f = {
          user = "greeter";
          group = "greeter";
          mode = "0640";
        };
      }
    ];
  };
}
