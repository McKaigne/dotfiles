{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
    ];
  };
in
{
  flake.nixosModules.tmux = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      tmuxDeps = [
        pkgs.fzf
        pkgs.lazygit
        pkgs.python3
        self'.packages.yazi
        self'.packages.helix
        self'.packages.nushell
      ];

      wrappedTmux = pkgs.symlinkJoin {
        name = "tmux";
        paths = [ pkgs.tmux ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tmux \
            --prefix PATH : ${lib.makeBinPath tmuxDeps} \
            --set TMUX_CONF "${./tmux.conf}" \
            --add-flags "-f ${./tmux.conf}"
        '';
      };
    in
    {
      packages.tmux = wrappedTmux;

      apps.tmux = {
        type = "app";
        program = "${wrappedTmux}/bin/tmux";
        meta.description = "Hermetically wrapped Tmux terminal multiplexer with popups and statusline";
      };
    };
}