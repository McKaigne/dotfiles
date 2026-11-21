{
  flake.modules.nixos.helium =
    { config, ... }:
    {
      systemd.tmpfiles.settings."10-noctalia-chromium"."/etc/chromium/policies/managed/noctalia-color.json".f =
        {
          user = config.workstation.username;
          group = config.users.users.${config.workstation.username}.group;
          mode = "0644";
          argument = "{}";
        };

      programs.chromium = {
        enable = true;
        homepageLocation = "https://api.noctalia.dev/repos/dashboard";
        defaultSearchProviderEnabled = true;
        defaultSearchProviderSearchURL = "https://www.google.com/search?q={searchTerms}";
        defaultSearchProviderSuggestURL = "https://suggestqueries.google.com/complete/search?output=chrome&q={searchTerms}";

        extensions = [
          "nngceckbapebfimnlniiiahkandclblb"
          "eimadpbcbfnmbkopoojfekhnkhdbieeh"
          "mnjggcdmjocbbbhaepdhchncahnbgone"
        ];

        extraOpts = {
          HomepageIsNewTabPage = false;
          RestoreOnStartup = 1;
          SearchSuggestEnabled = true;
          DefaultSearchProviderName = "Google";
          DefaultSearchProviderKeyword = "google.com";
        };
      };
    };
}
