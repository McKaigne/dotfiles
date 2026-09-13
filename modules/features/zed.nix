{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor
    ];
  };
in
{
  flake.nixosModules.zed = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      fixedCursor = self'.packages.bibata-cursors-fixed;
      iconPath = "${fixedCursor}/share/icons:/run/current-system/sw/share/icons";

      zedRuntimeDeps = with pkgs; [
        direnv
        git
        wl-clipboard
      ];

      zedSettings = pkgs.writeText "settings.json" (builtins.toJSON {
        helix_mode = true;
        theme = "Noctalia Dark";
        load_direnv = "shell_hook";
        buffer_font_family = "Maple Mono NF";
        buffer_font_size = 14;
        ui_font_family = "Maple Mono NF";
        ui_font_size = 14;
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        vim = {
          use_system_clipboard = "always";
        };
      });

      wrappedZed = pkgs.symlinkJoin {
        name = "zed-editor";
        paths = [ pkgs.zed-editor ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zeditor \
            --prefix PATH : ${lib.makeBinPath zedRuntimeDeps} \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}" \
            --run '
              ZED_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/zed"
              mkdir -p "$ZED_DIR"
              if [ ! -f "$ZED_DIR/settings.json" ]; then
                cp "${zedSettings}" "$ZED_DIR/settings.json"
                chmod u+w "$ZED_DIR/settings.json"
              fi
            '

          [ -e $out/bin/zed ] || ln -sf $out/bin/zeditor $out/bin/zed
          [ -e $out/bin/zed-editor ] || ln -sf $out/bin/zeditor $out/bin/zed-editor
        '';
      };
    in
    {
      packages.zed-editor = wrappedZed;
      packages.zed = wrappedZed;

      apps.zed-editor = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with Helix mode, direnv, and Noctalia Dark theme";
      };
      apps.zed = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with Helix mode, direnv, and Noctalia Dark theme";
      };
    };
}