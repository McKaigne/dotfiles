{ self, inputs, ... }: {
  flake.nixosModules.librewolf =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          librewolf = prev.librewolf.override {
            nativeMessagingHosts = [
              prev.tridactyl-native
            ];
          };
        })
      ];

      environment.systemPackages = [
        pkgs.librewolf
        pkgs.tridactyl-native
      ];

      environment.etc."librewolf/policies/policies.json".text = builtins.toJSON {
        policies = {
          DisableAppUpdate = true;
          DisableTelemetry = true;
          DisablePocket = true;
          DisableFirefoxStudies = true;
          DisableFeedbackCommands = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";

          ExtensionSettings = {
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
            };
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
            };
            "{c84d89d9-a826-4015-957b-affebd9eb603}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/mal-sync/latest.xpi";
            };
            "enhancerforyoutube@maximerf.addons.mozilla.org" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
            };
            "sponsorBlocker@ajay.app" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
            };
            "tridactyl.vim@cmcaine.co.uk" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim/latest.xpi";
            };
            "{3c078156-979c-498b-8990-85f7987dd929}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/sidebery/latest.xpi";
            };
            "addon@darkreader.org" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
            };
            "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/styl-us/latest.xpi";
            };
            "{7aa7c68a-141f-45c9-a1c6-6e7382debbe1}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/catppuccin-mocha/latest.xpi";
            };
            "{26b4f076-089c-4c69-8497-44b7e5c9faef}" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/socialfocus/latest.xpi";
            };
          };

          Preferences = {
            "network.trr.mode" = {
              Value = 3;
              Status = "locked";
            };
            "network.trr.uri" = {
              Value = "https://dns.quad9.net/dns-query";
              Status = "locked";
            };
            "toolkit.legacyUserProfileCustomizations.stylesheets" = {
              Value = true;
              Status = "locked";
            };
            "privacy.clearOnShutdown.cookies" = {
              Value = false;
              Status = "locked";
            };
            "privacy.clearOnShutdown_v2.cookiesAndStorage" = {
              Value = false;
              Status = "locked";
            };
            "privacy.clearOnShutdown.history" = {
              Value = false;
              Status = "locked";
            };
            "network.cookie.lifetimePolicy" = {
              Value = 0;
              Status = "locked";
            };

            "ui.systemUsesDarkTheme" = {
              Value = 1;
              Status = "locked";
            };
            "layout.css.prefers-color-scheme.content-override" = {
              Value = 0;
              Status = "locked";
            };
            "browser.in-content.dark-mode" = {
              Value = true;
              Status = "locked";
            };

            "browser.startup.page" = {
              Value = 3;
              Status = "locked";
            };
            "browser.sessionstore.resume_from_crash" = {
              Value = true;
              Status = "locked";
            };
            "browser.sessionstore.max_resumed_crashes" = {
              Value = -1;
              Status = "locked";
            };
            "browser.sessionstore.resuming_after_os_restart" = {
              Value = true;
              Status = "locked";
            };
          };
        };
      };

      environment.etc."firefox/policies/policies.json".source =
        config.environment.etc."librewolf/policies/policies.json".source;

      home-manager.users.${user} = {
        xdg.configFile."tridactyl/tridactylrc" = {
          text = ''
            colours dark
          '';
          force = true;
        };
        home.file.".tridactylrc" = {
          text = ''
            colours dark
          '';
          force = true;
        };

        programs.librewolf = {
          enable = true;
          profiles.default = {
            id = 0;
            name = "default";
            isDefault = true;
            userChrome = builtins.readFile ./userChrome.css;
            userContent = builtins.readFile ./userContent.css;
            settings = {
              "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
              "privacy.clearOnShutdown.cookies" = false;
              "privacy.clearOnShutdown_v2.cookiesAndStorage" = false;
              "privacy.clearOnShutdown.history" = false;
              "network.cookie.lifetimePolicy" = 0;
              "ui.systemUsesDarkTheme" = 1;
              "layout.css.prefers-color-scheme.content-override" = 0;
              "browser.in-content.dark-mode" = true;
              "browser.startup.page" = 3;
              "browser.sessionstore.resume_from_crash" = true;
              "browser.sessionstore.max_resumed_crashes" = -1;
              "browser.sessionstore.resuming_after_os_restart" = true;
            };
          };
        };
      };
    };
}
