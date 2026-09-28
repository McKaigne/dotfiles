{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix
    ];
  };
in
{
  flake.nixosModules.helix = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      noctaliaTheme = pkgs.writeText "noctalia.toml" ''
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

      helixData = pkgs.runCommand "helix-data" {} ''
        mkdir -p $out/share/helix/themes
        cp ${noctaliaTheme} $out/share/helix/themes/noctalia.toml
      '';

      helixConfig = pkgs.writeText "helix-config.toml" ''
        theme = "noctalia"

        [editor]
        line-number = "relative"
        mouse = false
        cursorline = true
        color-modes = true
        bufferline = "always"
        auto-save = true
        idle-timeout = 50
        completion-trigger-len = 1

        [editor.cursor-shape]
        normal = "block"
        insert = "bar"
        select = "block"

        [editor.soft-wrap]
        enable = true

        [editor.statusline]
        left = ["mode", "spinner", "file-name", "file-modification-indicator"]
        right = ["diagnostics", "selections", "position", "file-encoding", "file-type"]

        [keys.normal]
        "C-s" = ":w"
        "C-q" = ":q"
        space.w = ":w"
        space.q = ":q"
      '';

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${lib.makeBinPath [ pkgs.marksman pkgs.nixd pkgs.nixfmt pkgs.gnused ]}" \
            --prefix XDG_DATA_DIRS : "${helixData}/share" \
            --add-flags "--config ${helixConfig}"
          [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
        '';
      };
    in
    {
      packages.helix = wrappedHelix;

      apps.helix = {
        type = "app";
        program = "${wrappedHelix}/bin/hx";
        meta.description = "Helix modal editor with bundled theme and language servers";
      };
    };
}
