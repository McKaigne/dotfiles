{ self, inputs, ... }:
let
  nixosModule = { config, pkgs, ... }:
    let
      user = config.mainUser;
      userHome = config.users.users.${user}.home;

      noctaliaConfig = pkgs.writeText "noctalia.toml" (
        builtins.replaceStrings [ "@user@" ] [ user ] (builtins.readFile ./config.toml)
      );

      noctaliaSettings = pkgs.writeText "settings.json" (
        builtins.replaceStrings [ "@user@" ] [ user ] (builtins.readFile ./settings.json)
      );

      cliampTemplate = ./cliamp-template.toml;
      themeSyncHook = pkgs.writeScript "theme-sync.sh" (builtins.readFile ./theme-sync.sh);

      initialNiriKdl = pkgs.writeText "noctalia.kdl" ''
        layout {
          focus-ring {
            active-color "#cba6f7"
            inactive-color "#1e1e2e"
            urgent-color "#f38ba8"
          }
          border {
            active-color "#cba6f7"
            inactive-color "#1e1e2e"
            urgent-color "#f38ba8"
          }
        }
      '';

      initialGhosttyTheme = pkgs.writeText "ghostty-noctalia" ''
        background = 1e1e2e
        foreground = cdd6f4
        cursor-color = cba6f7
        selection-background = 313244
        selection-foreground = cdd6f4

        palette = 0=#1e1e2e
        palette = 1=#f38ba8
        palette = 2=#a6e3a1
        palette = 3=#f9e2af
        palette = 4=#89b4fa
        palette = 5=#f5c2e7
        palette = 6=#94e2d5
        palette = 7=#cdd6f4
        palette = 8=#45475a
        palette = 9=#f38ba8
        palette = 10=#a6e3a1
        palette = 11=#f9e2af
        palette = 12=#89b4fa
        palette = 13=#f5c2e7
        palette = 14=#94e2d5
        palette = 15=#ffffff
      '';

      initialHelixTheme = pkgs.writeText "helix-noctalia.toml" ''
        "attribute" = { fg = "#cba6f7", modifiers = ["bold"] }
        "type" = "#cba6f7"
        "constructor" = "#94e2d5"
        "constant" = "#fab387"
        "string" = "#94e2d5"
        "comment" = { fg = "#585b70", modifiers = ["italic"] }
        "variable" = "#cdd6f4"
        "keyword" = { fg = "#cba6f7", modifiers = ["bold"] }
        "function" = "#94e2d5"
        "ui.background" = "none"
        "ui.cursor" = { fg = "#11111b", bg = "#cba6f7" }
        "ui.linenr" = "#585b70"
        "ui.linenr.selected" = "#cba6f7"
        "ui.statusline" = { fg = "#cdd6f4", bg = "#181825" }
        "ui.selection" = { bg = "#313244" }
      '';

      initialFuzzelTheme = pkgs.writeText "fuzzel-noctalia" ''
        [colors]
        background=1e1e2eff
        text=cdd6f4ff
        match=cba6f7ff
        selection=313244ff
        selection-text=cdd6f4ff
        selection-match=f38ba8ff
        border=cba6f7ff
      '';
    in
    {
      environment.systemPackages = [
        self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia
      ];

      systemd.tmpfiles.rules = [
        "d ${userHome}/.config/noctalia 0755 ${user} users -"
        "d ${userHome}/.config/noctalia/templates 0755 ${user} users -"
        "d ${userHome}/.config/noctalia/hooks 0755 ${user} users -"
        "d ${userHome}/.config/niri 0755 ${user} users -"
        "d ${userHome}/.config/ghostty/themes 0755 ${user} users -"
        "d ${userHome}/.config/helix/themes 0755 ${user} users -"
        "d ${userHome}/.config/fuzzel/themes 0755 ${user} users -"
        "d ${userHome}/.config/cliamp/themes 0755 ${user} users -"
        "d ${userHome}/Pictures/Wallpapers 0755 ${user} users -"

        "C+ ${userHome}/.config/noctalia/config.toml 0644 ${user} users - ${noctaliaConfig}"
        "C+ ${userHome}/.config/noctalia/settings.json 0644 ${user} users - ${noctaliaSettings}"
        "C+ ${userHome}/.config/noctalia/templates/cliamp.toml 0644 ${user} users - ${cliampTemplate}"
        "C+ ${userHome}/.config/noctalia/hooks/theme-sync.sh 0755 ${user} users - ${themeSyncHook}"

        "C+ ${userHome}/.config/niri/noctalia.kdl 0644 ${user} users - ${initialNiriKdl}"
        "C+ ${userHome}/.config/ghostty/themes/noctalia 0644 ${user} users - ${initialGhosttyTheme}"
        "C+ ${userHome}/.config/helix/themes/noctalia.toml 0644 ${user} users - ${initialHelixTheme}"
        "C+ ${userHome}/.config/fuzzel/themes/noctalia 0644 ${user} users - ${initialFuzzelTheme}"
      ];
    };
in
{
  flake.nixosModules.noctalia = nixosModule;

  perSystem = { pkgs, ... }:
    let
      rawNoctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages.noctalia = rawNoctalia;

      apps.noctalia = {
        type = "app";
        program = "${rawNoctalia}/bin/noctalia";
        meta.description = "Noctalia v5 native C++ Wayland desktop shell";
      };
    };
}
