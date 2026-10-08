{ self, inputs, ... }: {
  flake.nixosModules.fuzzel = { pkgs, ... }:
  let
    fuzzelIni = pkgs.writeText "fuzzel.ini" ''
      [main]
      font=Lilex Nerd Font:size=14
      prompt="➜ "
      lines=12
      width=35
      horizontal-pad=20
      vertical-pad=15
      inner-pad=10
      prefer-no-csd

      [colors]
      background=002b36d9
      text=839496ff
      prompt=2aa198ff
      placeholder=586e75ff
      input=93a1a1ff
      match=b58900ff
      selection=073642ff
      selection-text=93a1a1ff
      selection-match=2aa198ff
      border=2aa198ff

      [border]
      width=1
      radius=12
    '';

    wrappedFuzzel = pkgs.symlinkJoin {
      name = "fuzzel";
      paths = [ pkgs.fuzzel ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/fuzzel \
          --add-flags "--config ${fuzzelIni}"
      '';
    };
  in
  {
    environment.systemPackages = [ wrappedFuzzel ];
  };
}
