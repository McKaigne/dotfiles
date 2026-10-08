{ self, inputs, ... }: {
  flake.nixosModules.helix = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    helixLspPath = lib.makeBinPath [
      pkgs.marksman
      pkgs.nixd
      pkgs.nixfmt
      pkgs.bash-language-server
      pkgs.shellcheck
      pkgs.shfmt
      pkgs.taplo
      pkgs.yaml-language-server
    ];

    wrappedHelix = pkgs.symlinkJoin {
      name = "helix-wrapped";
      paths = [ pkgs.helix ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/hx \
          --prefix PATH : "${helixLspPath}"
        [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
      '';
    };
  in
  {
    environment.systemPackages = [ wrappedHelix ];

    home-manager.users.${user} = {
      xdg.configFile."helix/config.toml".text = ''
        theme = "solarized_dark"

        [editor]
        line-number = "relative"
        mouse = false
        cursorline = true
        bufferline = "always"
        auto-save = true

        [editor.cursor-shape]
        normal = "block"
        insert = "bar"
        select = "block"

        [editor.indent-guides]
        render = true

        [editor.soft-wrap]
        enable = true

        [editor.lsp]
        display-inlay-hints = true
      '';
    };
  };
}
