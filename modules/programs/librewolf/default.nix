{
  inputs,
  config,
  ...
}: let
  flakeConfig = config;
in {
  flake.modules.nixos.librewolf = {
    config,
    pkgs,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    ff = inputs.firefox-addons.packages.${system};

    xpiPath = addon: "file://${addon}/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}/${addon.addonId}.xpi";
  in {
    home-manager.sharedModules = [
      flakeConfig.flake.modules.homeManager.librewolf
    ];

    nixpkgs.overlays = [
      (_final: prev: {
        librewolf = prev.librewolf.override {
          nativeMessagingHosts = [
            prev.tridactyl-native
          ];
        };
      })
    ];

    environment.systemPackages = with pkgs; [
      tridactyl-native
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
            install_url = xpiPath ff.ublock-origin;
          };
          "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.bitwarden;
          };
          "{c84d89d9-a826-4015-957b-affebd9eb603}" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.mal-sync;
          };
          "sponsorBlocker@ajay.app" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.sponsorblock;
          };
          "tridactyl.vim@cmcaine.co.uk" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.tridactyl;
          };
          "{3c078156-979c-498b-8990-85f7987dd929}" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.sidebery;
          };
          "addon@darkreader.org" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.darkreader;
          };
          "{7a7a4a92-a2a0-41d1-9fd7-1e92480d612d}" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.stylus;
          };
          "pywalfox@frewacom.org" = {
            installation_mode = "force_installed";
            install_url = xpiPath ff.pywalfox;
          };
          "enhancerforyoutube@maximerf.addons.mozilla.org" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/enhancer-for-youtube/latest.xpi";
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
          # Lets the window behind the toolbars be translucent (see userChrome.css).
          "browser.tabs.allow_transparent_browser" = {
            Value = true;
            Status = "locked";
          };
          # Gives the Wayland window an alpha channel for that translucency.
          "widget.transparent-windows" = {
            Value = true;
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
          "font.name.sans-serif.x-western" = {
            Value = "Maple Mono NF";
            Status = "locked";
          };
          "font.name.serif.x-western" = {
            Value = "Maple Mono NF";
            Status = "locked";
          };
          "font.name.monospace.x-western" = {
            Value = "Maple Mono NF";
            Status = "locked";
          };
          "font.default.x-western" = {
            Value = "monospace";
            Status = "locked";
          };
        };
      };
    };

    environment.etc."firefox/policies/policies.json".source =
      config.environment.etc."librewolf/policies/policies.json".source;
  };

  flake.modules.homeManager.librewolf = {
    config,
    lib,
    pkgs,
    ...
  }: let
    ff = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  in {
    home.sessionVariables.BROWSER = lib.getExe pkgs.librewolf;

    # Noctalia is the Pywalfox host and keeps ~/.mozilla/.../pywalfox.json pointed at
    # its current binary. LibreWolf only looks in ~/.librewolf, so link it there.
    home.file.".librewolf/native-messaging-hosts/pywalfox.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.mozilla/native-messaging-hosts/pywalfox.json";

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
        extensions = {
          force = true;
          packages = [
            ff.ublock-origin
            ff.bitwarden
            ff.mal-sync
            ff.sponsorblock
            ff.tridactyl
            ff.sidebery
            ff.darkreader
            ff.stylus
            ff.pywalfox
          ];
        };
        # Glass percentage comes from the shared style.
        userChrome =
          builtins.replaceStrings ["@GLASS_PERCENT@"]
          [(toString (builtins.floor ((import ../../appearance/_style.nix).opacity * 100)))]
          (builtins.readFile ./userChrome.css);
        userContent = builtins.readFile ./userContent.css;
      };
    };
  };
}
