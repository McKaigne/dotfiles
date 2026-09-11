{ self, ... }:

let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key
    ];
  };
in
{
  flake.nixosModules.whichKey = nixosModule;
  flake.nixosModules.wlrWhichKey = nixosModule;

  perSystem = { self', pkgs, ... }: let
    niriBin = "${pkgs.niri}/bin/niri";
    noctaliaBin = "${self'.packages.noctalia-shell}/bin/noctalia-shell";
    systemctlBin = "${pkgs.systemd}/bin/systemctl";
    loginctlBin = "${pkgs.systemd}/bin/loginctl";

    whichKeyConfig = pkgs.writeText "config.yaml" (builtins.replaceStrings
      [
        "@ghostty@"
        "@tmux@"
        "@lazygit@"
        "@btop@"
        "@wl_paste@"
        "@localsend@"
        "@noctalia@"
        "@niri@"
        "@systemctl@"
        "@loginctl@"
      ]
      [
        "${self'.packages.ghostty}/bin/ghostty"
        "${self'.packages.tmux}/bin/tmux"
        "${pkgs.lazygit}/bin/lazygit"
        "${self'.packages.btop}/bin/btop"
        "${pkgs.wl-clipboard}/bin/wl-paste"
        "${pkgs.localsend}/bin/localsend"
        noctaliaBin
        niriBin
        systemctlBin
        loginctlBin
      ]
      (builtins.readFile ./config.yaml)
    );

    whichKeyDir = pkgs.runCommand "wlr-which-key-config-dir" {} ''
      mkdir -p $out/wlr-which-key
      cp ${whichKeyConfig} $out/wlr-which-key/config.yaml
    '';

    wrappedWhichKey = pkgs.symlinkJoin {
      name = "wlr-which-key-wrapped";
      paths = [ pkgs.wlr-which-key ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/wlr-which-key \
          --set XDG_CONFIG_HOME "${whichKeyDir}"
        [ -e $out/bin/which-key ] || ln -sf $out/bin/wlr-which-key $out/bin/which-key
      '';
    };
  in {
    packages.which-key = wrappedWhichKey;
    packages.wlr-which-key = wrappedWhichKey;

    apps.which-key = {
      type = "app";
      program = "${wrappedWhichKey}/bin/wlr-which-key";
      meta.description = "Modal which-key menu overlay wrapped with hermetic config";
    };
    apps.wlr-which-key = {
      type = "app";
      program = "${wrappedWhichKey}/bin/wlr-which-key";
      meta.description = "Modal which-key menu overlay wrapped with hermetic config";
    };
  };
}