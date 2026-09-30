{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
  zjstatusWasm = pkgs.fetchurl {
    url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
    sha256 = "4de426d20b1cbf861272e927aeeb5b49d92c17f0e2bb9d173f85bf7f0154dd53";
  };

  zellijLayout = ''
    layout {
      pane
      pane size=1 borderless=true {
        plugin location="file:${zjstatusWasm}" {
          format_left   " {mode} #[fg=$fg,bold]□ {session}#[fg=$black]    {tabs}"
          format_center ""
          format_right  ""
          format_space  ""

          tab_normal   "#[fg=$black] {index} {name} #[fg=$black]·"
          tab_active   "#[fg=$fg,bold]▶ {index} {name} #[fg=$black]·"
          tab_sync     "#[fg=$yellow] "

          mode_locked  "#[fg=$black,bold]⬡ LOCKED"
          mode_normal  "#[fg=$magenta,bold]⬢ NORMAL"
          mode_pane    "#[fg=$cyan,bold]⬟ PANE"
          mode_tab     "#[fg=$yellow,bold]■ TAB"
          mode_resize  "#[fg=$blue,bold]▲ RESIZE"
          mode_scroll  "#[fg=$green,bold]● SCROLL"
          mode_session "#[fg=$orange,bold]◆ SESSION"
        }
      }
    }
  '';

  zellijConfig = ''
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
in
{
  environment.systemPackages = [ pkgs.zellij ];

  home-manager.users.${user} = {
    xdg.configFile."zellij/config.kdl" = {
      text = zellijConfig;
      force = true;
    };
    xdg.configFile."zellij/layouts/default.kdl" = {
      text = zellijLayout;
      force = true;
    };
  };
}
