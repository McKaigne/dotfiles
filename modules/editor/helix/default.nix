{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
  helixLspPath = lib.makeBinPath [
    pkgs.marksman
    pkgs.nixd
    pkgs.nixfmt
    pkgs.gnused
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
    xdg.configFile."helix/config.toml" = {
      source = ./config.toml;
      force = true;
    };
    xdg.configFile."helix/languages.toml" = {
      source = ./languages.toml;
      force = true;
    };
    xdg.configFile."helix/themes/noctalia-clean.toml" = {
      text = ''
        inherits = "noctalia"

        "ui.bufferline.active" = { fg = "onSurface", bg = "surfaceContainer" }
      '';
      force = true;
    };
  };
}
