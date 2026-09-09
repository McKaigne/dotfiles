{ inputs, self, ... }:
let
  nixosModule = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };
in
{
  flake.nixosModules.niri = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      niriRuntimeDeps = with pkgs; [
        xwayland-satellite
        self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
        self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty
        self.packages.${pkgs.stdenv.hostPlatform.system}.thunar
        self.packages.${pkgs.stdenv.hostPlatform.system}.helium
        self.packages.${pkgs.stdenv.hostPlatform.system}.emacs
        self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel
        self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key
        bemoji
        grim
        slurp
        wl-clipboard
        brightnessctl
        wireplumber
        playerctl
      ];

      noctaliaBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell}/bin/noctalia-shell";
      ghosttyBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty}/bin/ghostty";
      thunarBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.thunar}/bin/thunar";
      heliumBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.helium}/bin/helium";
      emacsBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.emacs}/bin/emacsclient";
      whichKeyBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key}/bin/wlr-which-key-menu";
      fuzzelBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.fuzzel}/bin/fuzzel";

      niriConfig = pkgs.writeText "config.kdl" ''
        prefer-no-csd

        hotkey-overlay {
            skip-at-startup
        }

        cursor {
            xcursor-theme "Bibata-Modern-Classic"
            xcursor-size 16
            hide-when-typing
            hide-after-inactive-ms 1000
        }

        input {
            warp-mouse-to-focus
            focus-follows-mouse
            keyboard {
                xkb {
                    layout "us"
                }
                repeat-rate 40
                repeat-delay 250
            }
            touchpad {
                tap
                natural-scroll
                dwt
                accel-speed 0.2
                accel-profile "adaptive"
                scroll-method "two-finger"
            }
            mouse {
                accel-profile "flat"
            }
        }

        layout {
            gaps 8
            default-column-width { proportion 0.5; }
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

        spawn-at-startup "${noctaliaBin}"
        spawn-at-startup "sh" "-c" "sleep 1 && ${noctaliaBin} ipc call wallpaper set \"$HOME/Pictures/Wallpapers/wallpaper.jpg\""
        xwayland-satellite

        binds {
            // Modal Which-Key Leader & Desktop Shell Controls
            Mod+Space { spawn "${whichKeyBin}"; }
            Mod+D { spawn "sh" "-c" "${noctaliaBin} ipc call launcher toggle || noctalia msg panel-toggle launcher"; }
            Mod+N { spawn "sh" "-c" "${noctaliaBin} ipc call controlCenter toggle || noctalia msg panel-toggle control-center"; }
            Mod+I { spawn "sh" "-c" "${noctaliaBin} ipc call settings toggle || noctalia msg settings-toggle"; }

            // Core Applications (Direct Recovery / Muscle Memory)
            Mod+Return { spawn "${ghosttyBin}"; }
            Mod+E { spawn "${thunarBin}"; }
            Mod+W { spawn "${heliumBin}"; }
            Mod+C { spawn "${emacsBin}" "-c" "-a" "emacs"; }

            // Quick Access Desktop Helpers
            Mod+Minus { set-column-width "-5%"; }
            Mod+Equal { set-column-width "+5%"; }
            Mod+Period { spawn "sh" "-c" "BEMOJI_PICKER_CMD='${fuzzelBin} -d' ${pkgs.bemoji}/bin/bemoji -c"; }
            Mod+Comma { spawn "sh" "-c" "${noctaliaBin} ipc call notifications dismiss || noctalia msg notification-dismiss"; }

            // Windows & Layout Actions
            Mod+Q { close-window; }
            Mod+F { maximize-column; }
            Mod+Shift+F { toggle-window-floating; }
            Mod+Shift+C { center-column; }
            Mod+R { switch-preset-column-width; }
            Mod+Shift+R { reset-window-height; }

            // Column & Workspace Navigation (Strict Vim Semantics)
            Mod+H { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+Shift+H { move-column-left; }
            Mod+Shift+L { move-column-right; }
            Mod+J { focus-workspace-down; }
            Mod+K { focus-workspace-up; }
            Mod+Shift+J { move-column-to-workspace-down; }
            Mod+Shift+K { move-column-to-workspace-up; }

            // Workspaces w0 - w9
            Mod+1 { focus-workspace "w0"; }
            Mod+2 { focus-workspace "w1"; }
            Mod+3 { focus-workspace "w2"; }
            Mod+4 { focus-workspace "w3"; }
            Mod+5 { focus-workspace "w4"; }
            Mod+6 { focus-workspace "w5"; }
            Mod+7 { focus-workspace "w6"; }
            Mod+8 { focus-workspace "w7"; }
            Mod+9 { focus-workspace "w8"; }
            Mod+0 { focus-workspace "w9"; }

            Mod+Shift+1 { move-column-to-workspace "w0"; }
            Mod+Shift+2 { move-column-to-workspace "w1"; }
            Mod+Shift+3 { move-column-to-workspace "w2"; }
            Mod+Shift+4 { move-column-to-workspace "w3"; }
            Mod+Shift+5 { move-column-to-workspace "w4"; }
            Mod+Shift+6 { move-column-to-workspace "w5"; }
            Mod+Shift+7 { move-column-to-workspace "w6"; }
            Mod+Shift+8 { move-column-to-workspace "w7"; }
            Mod+Shift+9 { move-column-to-workspace "w8"; }
            Mod+Shift+0 { move-column-to-workspace "w9"; }

            // Screenshots
            Mod+Shift+S { spawn "sh" "-c" "${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp -w 0)\" - | ${pkgs.wl-clipboard}/bin/wl-copy"; }
            Print { spawn "sh" "-c" "${pkgs.grim}/bin/grim -l 0 - | ${pkgs.wl-clipboard}/bin/wl-copy"; }

            // Hardware Display & Audio Controls
            XF86MonBrightnessUp { spawn "sh" "-c" "pct=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%'); new=$(( (pct / 5 * 5) + 5 )); [ $new -gt 100 ] && new=100; ${pkgs.brightnessctl}/bin/brightnessctl set ''${new}%"; }
            XF86MonBrightnessDown { spawn "sh" "-c" "pct=$(${pkgs.brightnessctl}/bin/brightnessctl -m | cut -d, -f4 | tr -d '%'); new=$(( ((pct - 1) / 5 * 5) )); [ $new -lt 5 ] && new=5; ${pkgs.brightnessctl}/bin/brightnessctl set ''${new}%"; }
            XF86AudioRaiseVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%+"; }
            XF86AudioLowerVolume { spawn "${pkgs.wireplumber}/bin/wpctl" "set-volume" "-l" "1.4" "@DEFAULT_AUDIO_SINK@" "5%-"; }
            XF86AudioMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioMicMute { spawn "${pkgs.wireplumber}/bin/wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"; }
            XF86AudioPlay { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
            XF86AudioPause { spawn "${pkgs.playerctl}/bin/playerctl" "play-pause"; }
            XF86AudioNext { spawn "${pkgs.playerctl}/bin/playerctl" "next"; }
            XF86AudioPrev { spawn "${pkgs.playerctl}/bin/playerctl" "previous"; }
        }

        // Live Noctalia Palette Runtime Hook
        include optional=true "~/.config/niri/noctalia.kdl"
      '';

      wrappedNiri = pkgs.symlinkJoin {
        name = "niri";
        paths = [ pkgs.niri ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        passthru = {
          providedSessions = [ "niri" ];
        };
        postBuild = ''
          wrapProgram $out/bin/niri \
            --prefix PATH : ${lib.makeBinPath niriRuntimeDeps} \
            --add-flags "--config" --add-flags "${niriConfig}"
        '';
      };
    in
    {
      packages.niri = wrappedNiri;
      packages.default = wrappedNiri;

      apps.niri = {
        type = "app";
        program = "${wrappedNiri}/bin/niri";
        meta.description = "Hermetically wrapped Niri scrollable-tiling compositor";
      };

      apps.default = {
        type = "app";
        program = "${wrappedNiri}/bin/niri";
        meta.description = "Default session (Niri)";
      };
    };
}