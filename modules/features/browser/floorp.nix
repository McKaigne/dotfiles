{ self, inputs, ... }: {
  flake.nixosModules.floorp = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [
      pkgs.floorp-bin
      pkgs.tridactyl-native
    ];

    environment.etc."floorp/native-messaging-hosts/tridactyl.json".source =
      "${pkgs.tridactyl-native}/share/domingo/tridactyl.json";
    environment.etc."mozilla/native-messaging-hosts/tridactyl.json".source =
      "${pkgs.tridactyl-native}/share/domingo/tridactyl.json";

    environment.etc."floorp/policies/policies.json".text = builtins.toJSON {
      policies = {
        DisableAppUpdate = true;
        DisableTelemetry = true;
        DisablePocket = true;

        Preferences = {
          "xpinstall.signatures.required" = false;
          "extensions.experiments.enabled" = true;
        };

        ExtensionSettings = {
          # Solarized Osaka Browser Theme
          "solarized-osaka@hhschen.local" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/solarized-osaka/latest.xpi";
          };

          # Sidebery
          "{3c078156-979c-498b-8990-85f7987dd929}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
          };

          # Tridactyl
          "tridactyl.vim@cmcaine.co.uk" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
          };

          # Bitwarden
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          };

          # SponsorBlock
          "sponsorBlocker@ajay.app" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          };

          # uBlock Origin
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
        };
      };
    };

    environment.etc."firefox/policies/policies.json".source =
      config.environment.etc."floorp/policies/policies.json".source;
  };
}
