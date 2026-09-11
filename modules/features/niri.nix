{ self, ... }:

let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.niri
      pkgs.xwayland-satellite
    ];
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };
in
{
  flake.nixosModules.niri = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, lib, ... }: let
    noctaliaShellBin = "${self'.packages.noctalia-shell}/bin/noctalia-shell";

    niriConfig = pkgs.writeText "config.kdl" ''
      prefer-no-csd

      hotkey-overlay {
        skip-at-startup
      }

      input {
        warp-mouse-to-focus
        focus-follows-mouse
        touchpad {
          tap
          natural-scroll
        }
      }

      cursor {
        xcursor-theme "Bibata-Modern-Classic"
        xcursor-size 16
      }

      environment {
        XCURSOR_THEME "Bibata-Modern-Classic"
        XCURSOR_SIZE "16"
      }

      layout {
        gaps 8
        focus-ring {
          width 2
        }
        preset-column-widths {
          proportion 0.33333
          proportion 0.5
          proportion 0.66667
          proportion 1.0
        }
      }

      workspace "w0"
      workspace "w1"
      workspace "w2"
      workspace "w3"
      workspace "w4"
      workspace "w5"
      workspace "w6"
      workspace "w7"
      workspace "w8"
      workspace "w9"

      spawn-at-startup "${noctaliaShellBin}"
      spawn-at-startup "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
      spawn-at-startup "${pkgs.systemd}/bin/systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"

      binds {
        Mod+Space { spawn "${self'.packages.wlr-which-key}/bin/wlr-which-key"; }
        Mod+D     { spawn "${noctaliaShellBin}" "ipc" "call" "launcher" "toggle"; }
        Mod+N     { spawn "${noctaliaShellBin}" "ipc" "call" "controlCenter" "toggle"; }
        Mod+I     { spawn "${noctaliaShellBin}" "ipc" "call" "settings" "toggle"; }
        Mod+Comma { spawn "${noctaliaShellBin}" "ipc" "call" "notifications" "dismiss"; }
        Mod+Period { spawn "${noctaliaShellBin}" "ipc" "call" "launcher" "emoji"; }

        Mod+Return { spawn "${self'.packages.ghostty}/bin/ghostty"; }
        Mod+E      { spawn "${self'.packages.thunar}/bin/thunar"; }
        Mod+W      { spawn "${self'.packages.helium}/bin/helium"; }
        Mod+C      { spawn "${self'.packages.emacs}/bin/emacsclient" "-c" "-a" "emacs"; }

        Mod+Q       { close-window; }
        Mod+F       { maximize-column; }
        Mod+Shift+F { toggle-window-floating; }
        Mod+Shift+C { center-column; }
        Mod+Minus   { set-column-width "-5%"; }
        Mod+Equal   { set-column-width "+5%"; }

        Mod+R       { reset-window-height; }
        Mod+Alt+H   { switch-preset-column-width-back; }
        Mod+Alt+L   { switch-preset-column-width; }

        Mod+H { focus-column-left; }
        Mod+L { focus-column-right; }
        Mod+Shift+H { move-column-left; }
        Mod+Shift+L { move-column-right; }
        Mod+J { focus-workspace-down; }
        Mod+K { focus-workspace-up; }
        Mod+Shift+J { move-column-to-workspace-down; }
        Mod+Shift+K { move-column-to-workspace-up; }

        ${lib.concatMapStringsSep "\n        " (i: let ws = toString i; in ''
          Mod+${ws} { focus-workspace "w${ws}"; }
          Mod+Shift+${ws} { move-column-to-workspace "w${ws}"; }
        '') (lib.range 1 9)}

        Mod+0 { focus-workspace "w0"; }
        Mod+Shift+0 { move-column-to-workspace "w0"; }

        Mod+Shift+S { spawn-sh "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"; }
        Print       { spawn-sh "${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy"; }

        XF86MonBrightnessUp   { spawn-sh "${pkgs.brightnessctl}/bin/brightnessctl set +5%"; }
        XF86MonBrightnessDown { spawn-sh "curr=$(${pkgs.brightnessctl}/bin/brightnessctl get); max=$(${pkgs.brightnessctl}/bin/brightnessctl max); new=$((curr - max * 5 / 100)); [ ''${new} -lt $((max * 5 / 100)) ] && ${pkgs.brightnessctl}/bin/brightnessctl set 5% || ${pkgs.brightnessctl}/bin/brightnessctl set 5%-"; }

        XF86AudioRaiseVolume  { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+"; }
        XF86AudioLowerVolume  { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-"; }
        XF86AudioMute         { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
        XF86AudioMicMute      { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
        XF86AudioPlay         { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
        XF86AudioNext         { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
        XF86AudioPrev         { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }
      }

      include optional=true "~/.config/niri/noctalia.kdl"
    '';
  in {
    packages.niri = pkgs.symlinkJoin {
      name = "niri-wrapped";
      paths = [ pkgs.niri ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = (pkgs.niri.passthru or { }) // {
        providedSessions = [ "niri" ];
      };
      postBuild = ''
        wrapProgram $out/bin/niri \
          --add-flags "--config ${niriConfig}"
      '';
    };

    apps.niri = {
      type = "app";
      program = "${self'.packages.niri}/bin/niri";
      meta.description = "Scrollable-tiling Wayland compositor wrapped with hermetic config";
    };
  };
}