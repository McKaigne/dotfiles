{ pkgs, ... }:
let
  fuzzelConfig = pkgs.writeText "fuzzel.ini" (builtins.readFile ./fuzzel.ini);
  wrappedFuzzel = pkgs.symlinkJoin {
    name = "fuzzel";
    paths = [ pkgs.fuzzel ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/fuzzel \
        --add-flags "--config ${fuzzelConfig}"
    '';
  };
in
{
  environment.systemPackages = [ wrappedFuzzel ];
}
