{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/41-lockscreen.toml".source = (pkgs.formats.toml {}).generate "41-lockscreen.toml" {
      "lockscreen" = {
        "blur_intensity" = 0.0;
        "fingerprint" = false;
        # Lid close and every other suspend lock first (Noctalia's default,
        # pinned: idle.nix never locks, so this is castor's only auto-lock).
        "lock_before_suspend" = true;
        "tint_intensity" = 0.0;
        "transition" = [
          "stripes"
        ];
      };
    };
  };
}
