{ self, inputs, ... }: {
  flake.nixosModules.brave = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [ pkgs.brave-origin ];

    environment.etc."brave/policies/managed/brave-policies.json".text = builtins.toJSON {
      RestoreOnStartup = 1;
      UseCustomChromeFrame = false;
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = true;
      BraveAIChatEnabled = false;
      BraveNewsDisabled = true;
      BraveTalkDisabled = true;
      BraveP3AEnabled = false;
      BraveStatsPingEnabled = false;
      BraveWebDiscoveryEnabled = false;
      TorDisabled = true;
      SyncDisabled = true;
      PasswordManagerEnabled = false;
      MetricsReportingEnabled = false;
      DnsOverHttpsMode = "secure";
      DnsOverHttpsTemplates = "https://dns.quad9.net/dns-query";

      ExtensionInstallAllowlist = [ "*" ];
      ExtensionInstallForcelist = [
        "hfjbmagddngcpeloejdejnfgbamkjaeg;https://clients2.google.com/service/update2/crx"
        "kkeakohpadmbldjaiggikmnldlfkdfog;https://clients2.google.com/service/update2/crx"
        "abocjojdmemdpiffeadpdnicnlhcndcg;https://clients2.google.com/service/update2/crx"
        "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
        "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx"
      ];
    };

    environment.etc."brave-origin/policies/managed/brave-origin-policies.json".source =
      config.environment.etc."brave/policies/managed/brave-policies.json".source;

    environment.etc."chromium/policies/managed/brave-policies.json".source =
      config.environment.etc."brave/policies/managed/brave-policies.json".source;

    home-manager.users.${user} = { lib, ... }: {
      home.activation.setupBraveSymlinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
        TARGET_DIR="$HOME/.config/BraveSoftware"
        mkdir -p "$TARGET_DIR"
        if [ -d "$TARGET_DIR/Brave-Browser" ] && [ ! -L "$TARGET_DIR/Brave-Browser" ]; then
          rm -rf "$TARGET_DIR/Brave-Browser"
        fi
        ln -sfn "$TARGET_DIR/Brave-Origin" "$TARGET_DIR/Brave-Browser"
      '';
    };
  };
}
