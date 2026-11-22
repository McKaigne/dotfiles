{
  flake.modules.nixos."helium" = {config, ...}: {
    # Noctalia's theme color for Helium (see home.nix). The file is the user's
    # so the theme hook can rewrite it in place; the directory and the other
    # browser policies stay root's. The old community template's file is
    # removed: Noctalia could never write it (it renames a temp file into the
    # root-owned directory).
    systemd.tmpfiles.settings."10-noctalia-chromium" = {
      "/etc/chromium/policies/managed/helium-theme.json".f = {
        user = config.workstation.username;
        group = config.users.users.${config.workstation.username}.group;
        mode = "0644";
        argument = "{}";
      };
      "/etc/chromium/policies/managed/noctalia-color.json".r = {};
    };

    programs.chromium = {
      # Helium reads Chromium's Linux enterprise-policy directory. Bare extension
      # IDs make Helium route installation and updates through its extension proxy.
      enable = true;

      homepageLocation = "https://api.noctalia.dev/repos/dashboard";
      defaultSearchProviderEnabled = true;
      defaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
      defaultSearchProviderSuggestURL = "https://suggestqueries.google.com/complete/search?output=chrome&q={searchTerms}";

      # Kept barebones (Akko web driver, VIA). Helium ships uBlock Origin
      # built in, and Noctalia themes it through the policy file above, so
      # Pywalfox (Firefox-only anyway) is not needed.
      extensions = [
        "eimadpbcbfnmbkopoojfekhnkhdbieeh" # Dark Reader
      ];

      extraOpts = {
        HomepageIsNewTabPage = false;
        RestoreOnStartup = 1;
        SearchSuggestEnabled = true;
        DefaultSearchProviderName = "Google";
        DefaultSearchProviderKeyword = "google.com";

        SiteSearchSettings = [
          {
            name = "Google";
            shortcut = "g";
            url = "https://www.google.com/search?q={searchTerms}";
            featured = true;
          }
          {
            name = "SearxNG";
            shortcut = "searx";
            url = "https://searx.org/search?q={searchTerms}";
            featured = true;
          }
          {
            name = "Nix packages";
            shortcut = "np";
            url = "https://search.nixos.org/packages?type=packages&query={searchTerms}";
            featured = true;
          }
          {
            name = "NixOS Wiki";
            shortcut = "nw";
            url = "https://nixos.wiki/index.php?search={searchTerms}";
          }
          {
            name = "DuckDuckGo";
            shortcut = "ddg";
            url = "https://duckduckgo.com/?q={searchTerms}";
          }
        ];
      };
    };
  };
}
