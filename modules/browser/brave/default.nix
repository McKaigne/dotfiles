{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = [ pkgs.brave-origin ];

  # Declarative enterprise policies for Brave Origin
  environment.etc."brave/policies/managed/brave-policies.json".text = builtins.toJSON {
    RestoreOnStartup = 1; # Continue where you left off
    BraveRewardsDisabled = true;
    BraveWalletDisabled = true;
    BraveVPNDisabled = true;
    BraveAIChatEnabled = false; # Disable Leo AI
    BraveNewsDisabled = true;
    BraveTalkDisabled = true;
    BraveP3AEnabled = false;
    BraveStatsPingEnabled = false;
    BraveWebDiscoveryEnabled = false;
    TorDisabled = true;
    SyncDisabled = true;
    PasswordManagerEnabled = false; # Rely on Bitwarden
    MetricsReportingEnabled = false;
    DnsOverHttpsMode = "secure";
    DnsOverHttpsTemplates = "https://dns.quad9.net/dns-query";

    # Maintain Manifest V2 compatibility for uBlock Origin
    ExtensionManifestV2Availability = 2;

    # Allow local Noctalia theme extension
    ExtensionInstallAllowlist = [ "*" ];

    ExtensionInstallForcelist = [
      # Vimium C
      "gphhapmejobijbbhgpjhcjognlahblep;https://clients2.google.com/service/update2/crx"
      # Bitwarden
      "nngceckbapebfimnlniiiahkandclblb;https://clients2.google.com/service/update2/crx"
      # SponsorBlock
      "mnjggcdmjocbbbhaepdhchncahnbgone;https://clients2.google.com/service/update2/crx"
      # uBlock Origin (MV2)
      "cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx"
    ];
  };

  # Mirror policies to brave-origin and chromium paths
  environment.etc."brave-origin/policies/managed/brave-origin-policies.json".source =
    config.environment.etc."brave/policies/managed/brave-policies.json".source;

  environment.etc."chromium/policies/managed/brave-policies.json".source =
    config.environment.etc."brave/policies/managed/brave-policies.json".source;

  home-manager.users.${user} = { lib, ... }: {
    # Primary default browser associations
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "brave-browser.desktop";
        "x-scheme-handler/http" = "brave-browser.desktop";
        "x-scheme-handler/https" = "brave-browser.desktop";
        "x-scheme-handler/about" = "brave-browser.desktop";
        "x-scheme-handler/unknown" = "brave-browser.desktop";
      };
    };

    # Seed Vimium C keymappings (J/K tab cycle, d close tab)
    xdg.configFile."vimium-c/vimium_c.json".text = builtins.toJSON {
      keyMappings = [
        "map J previousTab"
        "map K nextTab"
        "map d removeTab"
      ];
    };

    # Force Chromium Wayland + GTK integration flags
    xdg.configFile."brave-flags.conf".text = ''
      --ozone-platform-hint=auto
      --gtk-version=4
    '';

    xdg.configFile."brave-origin-flags.conf".text = ''
      --ozone-platform-hint=auto
      --gtk-version=4
    '';

    xdg.configFile."chromium-flags.conf".text = ''
      --ozone-platform-hint=auto
      --gtk-version=4
    '';

    # Configure Brave Origin Preferences: Disable vertical tabs, enforce GTK system theme
    home.activation.setupBravePrefs = lib.hm.dag.entryAfter ["writeBoundary"] ''
      PREF_DIR="$HOME/.config/BraveSoftware/Brave-Origin/Default"
      PREF_FILE="$PREF_DIR/Preferences"
      mkdir -p "$PREF_DIR"
      if [ ! -f "$PREF_FILE" ]; then
        echo '{}' > "$PREF_FILE"
      fi
      ${pkgs.jq}/bin/jq '
        .brave = (.brave // {}) |
        .brave.vertical_tabs = (.brave.vertical_tabs // {}) |
        .brave.vertical_tabs.enabled = false |
        .browser = (.browser // {}) |
        .browser.custom_chrome_frame = false |
        .extensions = (.extensions // {}) |
        .extensions.theme = (.extensions.theme // {}) |
        .extensions.theme.use_system = true |
        .extensions.theme.system_theme = 1
      ' "$PREF_FILE" > "$PREF_FILE.tmp" && mv "$PREF_FILE.tmp" "$PREF_FILE"
    '';
  };
}
