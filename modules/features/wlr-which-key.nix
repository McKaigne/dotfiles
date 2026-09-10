{ self, ... }:

{
  perSystem = { self', pkgs, ... }: let
    niriBin = "${pkgs.niri}/bin/niri";
    noctaliaBin = "${self'.packages.noctalia-shell}/bin/noctalia-shell";
    systemctlBin = "${pkgs.systemd}/bin/systemctl";
    loginctlBin = "${pkgs.systemd}/bin/loginctl";

    whichKeyConfig = pkgs.writeText "config.yaml" ''
      font: "JetBrainsMono Nerd Font 11"
      background: "#1e1e2e"
      color: "#cdd6f4"
      border: "#89b4fa"
      border_width: 1
      corner_radius: 4
      column_spacing: 20
      menu:
        - key: "t"
          label: "Terminal"
          submenu:
            - key: "a"
              label: "Tmux Attach"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${self'.packages.tmux}/bin/tmux attach"
            - key: "g"
              label: "Lazygit"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${pkgs.lazygit}/bin/lazygit"
            - key: "d"
              label: "Lazydocker"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${pkgs.lazydocker}/bin/lazydocker"
            - key: "b"
              label: "Btop Monitor"
              cmd: "${self'.packages.ghostty}/bin/ghostty -e ${self'.packages.btop}/bin/btop"
        - key: "l"
          label: "LocalSend"
          submenu:
            - key: "c"
              label: "Send Clipboard"
              cmd: "${pkgs.wl-clipboard}/bin/wl-paste | ${pkgs.localsend}/bin/localsend"
            - key: "r"
              label: "Receive (Open App)"
              cmd: "${pkgs.localsend}/bin/localsend"
        - key: "n"
          label: "Noctalia"
          submenu:
            - key: "s"
              label: "Silence Notifications"
              cmd: "${noctaliaBin} ipc call notifications toggleSilence"
            - key: "c"
              label: "Clipboard History"
              cmd: "${noctaliaBin} ipc call launcher clipboard"
            - key: "b"
              label: "Toggle Shell Bar"
              cmd: "${noctaliaBin} ipc call bar toggle"
        - key: "w"
          label: "Window"
          submenu:
            - key: "t"
              label: "Toggle Float / Tile"
              cmd: "${niriBin} msg action toggle-window-floating"
            - key: "f"
              label: "Fullscreen Window"
              cmd: "${niriBin} msg action fullscreen-window"
            - key: "w"
              label: "Maximize Width"
              cmd: "${niriBin} msg action maximize-column"
            - key: "e"
              label: "Reset Window Height"
              cmd: "${niriBin} msg action reset-window-height"
        - key: "s"
          label: "System"
          submenu:
            - key: "s"
              label: "Power / Session Menu"
              cmd: "${noctaliaBin} ipc call sessionMenu toggle"
            - key: "l"
              label: "Lock Screen"
              cmd: "${loginctlBin} lock-session"
            - key: "z"
              label: "Suspend System"
              cmd: "${systemctlBin} suspend"
            - key: "r"
              label: "Reboot System"
              cmd: "${systemctlBin} reboot"
    '';
  in {
    packages.wlr-which-key = pkgs.symlinkJoin {
      name = "wlr-which-key-wrapped";
      paths = [ pkgs.wlr-which-key ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        makeWrapper ${pkgs.wlr-which-key}/bin/wlr-which-key $out/bin/wlr-which-key-menu \
          --add-flags "--config ${whichKeyConfig}"
      '';
    };

    apps.wlr-which-key = {
      type = "app";
      program = "${self'.packages.wlr-which-key}/bin/wlr-which-key-menu";
      meta.description = "Modal which-key menu overlay wrapped with hermetic config";
    };
  };

  flake.nixosModules.wlrWhichKey = { pkgs, ... }: {
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key ];
  };

  flake.nixosModules.castorConfiguration = { ... }: {
    imports = [ self.nixosModules.wlrWhichKey ];
  };
}