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
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }:
    let
      helixConfig = pkgs.writeText "helix-config.toml" ''
        theme = "noctalia"

        [editor]
        line-number = "relative"
        cursorline = true
        color-modes = true
        bufferline = "multiple"
        auto-pairs = true
        auto-format = true

        [editor.cursor-shape]
        insert = "block"
        normal = "block"
        select = "block"

        [editor.indent-guides]
        render = true
        character = "│"
        skip-levels = 1

        [editor.lsp]
        display-inlay-hints = true
        display-messages = true

        [editor.statusline]
        left = ["mode", "spinner", "file-name", "read-only-indicator", "file-modification-indicator"]
        center = ["diagnostics"]
        right = ["file-type", "file-encoding", "position", "position-percentage"]
        mode.normal = "NORMAL"
        mode.insert = "INSERT"
        mode.select = "SELECT"
      '';

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ pkgs.helix ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
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
        meta.description = "Hermetically wrapped Helix modal text editor";
      };
    };
}