{ self, inputs, ... }: {
  flake.nixosModules.floorp =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      stablePkgs = inputs.nixpkgs-stable.legacyPackages.${system};

      stableFloorp = stablePkgs.floorp-bin.override {
        nativeMessagingHosts = [
          pkgs.tridactyl-native
        ];
      };
    in
    {
      nixpkgs.overlays = [
        (final: prev: {
          floorp-bin = stableFloorp;
          floorp = stableFloorp;
        })
      ];

      environment.systemPackages = [
        stableFloorp
        pkgs.tridactyl-native
      ];

      environment.etc."floorp/policies/managed/policies.json".text = builtins.toJSON {
        policies = {
          DisableAppUpdate = true;
          DisableFirefoxStudies = true;
          DisableTelemetry = true;
          DisableFeedbackCommands = true;
          DisablePocket = true;
          OverrideFirstRunPage = "";
          OverridePostUpdatePage = "";
          Preferences = {
            "app.update.channel" = {
              Value = "release";
              Status = "locked";
            };
            "floorp.browser.experiments.enabled" = {
              Value = false;
              Status = "locked";
            };
            "experiments.supported" = {
              Value = false;
              Status = "locked";
            };
            "experiments.enabled" = {
              Value = false;
              Status = "locked";
            };
            "network.trr.mode" = {
              Value = 3;
              Status = "locked";
            };
            "network.trr.uri" = {
              Value = "https://dns.quad9.net/dns-query";
              Status = "locked";
            };
          };
        };
      };

      environment.etc."firefox/policies/managed/policies.json".source =
        config.environment.etc."floorp/policies/managed/policies.json".source;
    };
}
