{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/60-theme.toml".source =
        (pkgs.formats.toml { }).generate "60-theme.toml"
          {
            theme = {
              builtin = "Catppuccin";
              mode = "dark";
              source = "builtin";
              wallpaper_scheme = "m3-content";
              templates = {
                enable_builtin_templates = true;
                enable_community_templates = true;
                builtin_ids = [
                  "btop"
                  "cava"
                  "emacs"
                  "foot"
                  "gtk3"
                  "gtk4"
                  "kcolorscheme"
                  "qt"
                  "umbriel"
                ];
                community_ids = [
                  "chromium-based"
                  "pywalfox"
                  "bat"
                  "fzf"
                  "glow"
                  "lazygit"
                  "claude-code"
                ];
              };
            };
          };
    };
}
