{ self, ... }:

let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key
    ];
  };
in
{
  flake.nixosModules.wlrWhichKey = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, ... }: let
    niriBin = "${pkgs.niri}/bin/niri";
    noctaliaBin = "${self'.packages.noctalia-shell}/bin/noctalia-shell";
    systemctlBin = "${pkgs.systemd}/bin/systemctl";
    loginctlBin = "${pkgs.systemd}/bin/loginctl";

    whichKeyConfig = pkgs.writeText "config.yaml" ''
      font: "Maple Mono NF 12"
      background: "#1e1e2ed0"
      color: "#cdd6f4"
      border: "#89b4fa"
      separator: " ➜ "
      border_width: 1
      corner_r: 4
      padding: 15
      column_padding: 20
      anchor: center
      menu:
        - key: "t"
          desc: "Terminal"
          submenu:
            - key: "a"
              desc: "Tmux Attach"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${self'.packages.tmux}/bin/tmux attach"
            - key: "g"
              desc: "Lazygit"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${pkgs.lazygit}/bin/lazygit"
            - key: "b"
              desc: "Btop Monitor"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${self'.packages.btop}/bin/btop"
        - key: "l"
          desc: "LocalSend"
          submenu:
            - key: "c"
              desc: "Send Clipboard"
              cmd: "${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.localsend}/bin/localsend"
            - key: "r"
              desc: "Receive (Open App)"
              cmd: "${pkgs.localsend}/bin/localsend"
        - key: "n"
          desc: "Noctalia"
          submenu:
            - key: "s"
              desc: "Silence Notifications"
              cmd: "${noctaliaBin} ipc call notifications toggleSilence"
            - key: "c"
              desc: "Clipboard History"
              cmd: "${noctaliaBin} ipc call launcher clipboard"
            - key: "b"
              desc: "Toggle Shell Bar"
              cmd: "${noctaliaBin} ipc call bar toggle"
        - key: "w"
          desc: "Window"
          submenu:
            - key: "t"
              desc: "Toggle Float / Tile"
              cmd: "${niriBin} msg action toggle-window-floating"
            - key: "f"
              desc: "Fullscreen Window"
              cmd: "${niriBin} msg action fullscreen-window"
            - key: "w"
              desc: "Maximize Width"
              cmd: "${niriBin} msg action maximize-column"
            - key: "e"
              desc: "Reset Window Height"
              cmd: "${niriBin} msg action reset-window-height"
        - key: "s"
          desc: "System"
          submenu:
            - key: "s"
              desc: "Power / Session Menu"
              cmd: "${noctaliaBin} ipc call sessionMenu toggle"
            - key: "l"
              desc: "Lock Screen"
              cmd: "${loginctlBin} lock-session"
            - key: "z"
              desc: "Suspend System"
              cmd: "${systemctlBin} suspend"
            - key: "r"
              desc: "Reboot System"
              cmd: "${systemctlBin} reboot"
    '';

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
      '';
    };
  in {
    packages.wlr-which-key = wrappedWhichKey;

    apps.wlr-which-key = {
      type = "app";
      program = "${wrappedWhichKey}/bin/wlr-which-key";
      meta.description = "Modal which-key menu overlay wrapped with hermetic config";
    };
  };
}