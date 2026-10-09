{ self, inputs, ... }: {
  flake.nixosModules.zellij = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    zjstatusWasm = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
      sha256 = "4de426d20b1cbf861272e927aeeb5b49d92c17f0e2bb9d173f85bf7f0154dd53";
    };

    zellijLayout = ''
      layout {
        pane size=1 borderless=true {
          plugin location="file:${zjstatusWasm}" {
            format_left   " #[fg=#b58900,bold]● {session} #[fg=#586e75]•{tabs}"
            format_center ""
            format_right  "{mode} "
            format_space  "#[bg=NONE]"

            tab_normal   " #[fg=#839496]○ {index} {name} #[fg=#586e75]•"
            tab_active   " #[fg=#2aa198,bold]● {index} {name} #[fg=#586e75]•"
            tab_sync     " #[fg=#b58900,bold]󰓩 "

            mode_locked  "#[fg=#586e75]LCK"
            mode_normal  "#[fg=#d33682,bold]NOR #[fg=#839496][p]ane [t]ab [r]esize [s]croll [q]uit"
            mode_pane    "#[fg=#2aa198,bold]PAN #[fg=#839496][h/j/k/l]move [r]ight [d]own [x]close [f]ull"
            mode_tab     "#[fg=#b58900,bold]TAB #[fg=#839496][h/l]prev/next [n]ew [x]close [1-9]goto"
            mode_scroll  "#[fg=#859900,bold]SCR #[fg=#839496][j/k]down/up [d/u]page [s]earch"
            mode_resize  "#[fg=#268bd2,bold]RES #[fg=#839496][h/j/k/l]resize [+/-]grow/shrink"
            mode_session "#[fg=#cb4b16,bold]SES #[fg=#839496][d]etach [w]orkspace"
          }
        }
        pane
      }
    '';
  in
  {
    environment.systemPackages = [ pkgs.zellij ];

    home-manager.users.${user} = {
      xdg.configFile."zellij/config.kdl".text = ''
        pane_frames false
        default_layout "default"
        default_mode "locked"
        theme "noctalia"

        keybinds clear-defaults=true {
          locked {
            bind "Ctrl b" { SwitchToMode "Normal"; }
          }
          normal {
            bind "Ctrl b" { SwitchToMode "Locked"; }
            bind "Esc" { SwitchToMode "Locked"; }
            bind "Enter" { SwitchToMode "Locked"; }
            bind "p" { SwitchToMode "Pane"; }
            bind "t" { SwitchToMode "Tab"; }
            bind "r" { SwitchToMode "Resize"; }
            bind "s" { SwitchToMode "Scroll"; }
            bind "q" { Quit; }
          }
          pane {
            bind "Ctrl b" { SwitchToMode "Locked"; }
            bind "Esc" { SwitchToMode "Locked"; }
            bind "Enter" { SwitchToMode "Locked"; }
            bind "h" "Left" { MoveFocus "Left"; }
            bind "l" "Right" { MoveFocus "Right"; }
            bind "j" "Down" { MoveFocus "Down"; }
            bind "k" "Up" { MoveFocus "Up"; }
            bind "r" { NewPane "Right"; }
            bind "d" { NewPane "Down"; }
            bind "n" { NewPane; }
            bind "x" { CloseFocus; }
            bind "f" { ToggleFocusFullscreen; }
            bind "w" { ToggleFloatingPanes; }
            bind "z" { TogglePaneFrames; }
          }
          tab {
            bind "Ctrl b" { SwitchToMode "Locked"; }
            bind "Esc" { SwitchToMode "Locked"; }
            bind "Enter" { SwitchToMode "Locked"; }
            bind "h" "Left" { GoToPreviousTab; }
            bind "l" "Right" { GoToNextTab; }
            bind "n" { NewTab; }
            bind "x" { CloseTab; }
            bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
            bind "1" { GoToTab 1; SwitchToMode "Locked"; }
            bind "2" { GoToTab 2; SwitchToMode "Locked"; }
            bind "3" { GoToTab 3; SwitchToMode "Locked"; }
            bind "4" { GoToTab 4; SwitchToMode "Locked"; }
            bind "5" { GoToTab 5; SwitchToMode "Locked"; }
            bind "6" { GoToTab 6; SwitchToMode "Locked"; }
            bind "7" { GoToTab 7; SwitchToMode "Locked"; }
            bind "8" { GoToTab 8; SwitchToMode "Locked"; }
            bind "9" { GoToTab 9; SwitchToMode "Locked"; }
          }
          resize {
            bind "Ctrl b" { SwitchToMode "Locked"; }
            bind "Esc" { SwitchToMode "Locked"; }
            bind "Enter" { SwitchToMode "Locked"; }
            bind "h" "Left" { Resize "Increase Left"; }
            bind "j" "Down" { Resize "Increase Down"; }
            bind "k" "Up" { Resize "Increase Up"; }
            bind "l" "Right" { Resize "Increase Right"; }
            bind "=" "+" { Resize "Increase"; }
            bind "-" { Resize "Decrease"; }
          }
          scroll {
            bind "Ctrl b" { SwitchToMode "Locked"; }
            bind "Esc" { SwitchToMode "Locked"; }
            bind "Enter" { SwitchToMode "Locked"; }
            bind "e" { EditScrollback; SwitchToMode "Locked"; }
            bind "s" { SwitchToMode "EnterSearch"; SearchInput 0; }
            bind "j" "Down" { ScrollDown; }
            bind "k" "Up" { ScrollUp; }
            bind "d" { HalfPageScrollDown; }
            bind "u" { HalfPageScrollUp; }
          }
        }
      '';
      xdg.configFile."zellij/layouts/default.kdl" = {
        text = zellijLayout;
        force = true;
      };
    };
  };
}
