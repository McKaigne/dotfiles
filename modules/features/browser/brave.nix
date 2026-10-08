{ self, inputs, ... }: {
  flake.nixosModules.brave = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [ pkgs.brave-origin ];

    environment.etc."brave/policies/managed/brave-policies.json".text = builtins.toJSON {
      RestoreOnStartup = 1;
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

      # Desaturate Brave: Force Base03 dark teal frame matching Solarized Osaka
      BrowserThemeColor = "#002b36";

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

        # Enforce non-custom frame so Brave fills the Niri window without corner gaps
        PREF_DIR="$HOME/.config/BraveSoftware/Brave-Origin/Default"
        PREF_FILE="$PREF_DIR/Preferences"
        mkdir -p "$PREF_DIR"
        if [ ! -f "$PREF_FILE" ]; then
          echo '{}' > "$PREF_FILE"
        fi
        ${pkgs.jq}/bin/jq '
          .browser = (.browser // {}) |
          .browser.custom_chrome_frame = false |
          .brave = (.brave // {}) |
          .brave.vertical_tabs = (.brave.vertical_tabs // {}) |
          .brave.vertical_tabs.enabled = false
        ' "$PREF_FILE" > "$PREF_FILE.tmp" && mv "$PREF_FILE.tmp" "$PREF_FILE"
      '';
    };
  };
}
