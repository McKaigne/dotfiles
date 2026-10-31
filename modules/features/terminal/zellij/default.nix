_: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      zjstatusWasm = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
        sha256 = "282ceab219e56e1908c9fac33907241fe6c3e1ef7d85faab3e5f438cef87b8fe";
      };

      sesh = pkgs.writeScriptBin "sesh" ''
        #! /usr/bin/env sh
        ZOXIDE_RESULT=$(zoxide query --interactive 2>/dev/null)
        if [ -z "$ZOXIDE_RESULT" ]; then
          exit 0
        fi
        SESSION_TITLE=$(basename "$ZOXIDE_RESULT")
        SESSION_LIST=$(zellij list-sessions -n 2>/dev/null | awk '{print $1}')

        if echo "$SESSION_LIST" | grep -q "^$SESSION_TITLE$"; then
          exec zellij attach "$SESSION_TITLE"
        else
          cd "$ZOXIDE_RESULT" && exec zellij attach -c "$SESSION_TITLE"
        fi
      '';

      zellijWrapped = pkgs.symlinkJoin {
        name = "zellij-${pkgs.zellij.version}";
        version = pkgs.zellij.version;
        paths = [ pkgs.zellij ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          rm -f $out/bin/zellij
          cat << 'WRAPPER' > $out/bin/zellij
#!/usr/bin/env sh
mkdir -p "$HOME/.cache/zellij"
if ! grep -Fq "${zjstatusWasm}" "$HOME/.cache/zellij/permissions.kdl" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.cache/zellij/permissions.kdl"
"${zjstatusWasm}" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
}
"file://${zjstatusWasm}" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
}
EOF
fi
exec ${pkgs.zellij}/bin/zellij "$@"
WRAPPER
          chmod +x $out/bin/zellij
        '';
      };
    in
    {
      environment.systemPackages = [
        zellijWrapped
        sesh
      ];

      home-manager.users.${user} = {
        programs.zellij = {
          enable = true;
          package = zellijWrapped;
        };

        xdg.configFile."zellij/config.kdl" = {
          text = ''
            theme "catppuccin-mocha"
            simplified_ui true
            default_shell "fish"
            pane_frames false
            mouse_mode true
            copy_on_select true
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
            copy_clipboard "system"
            session_serialization true
            show_startup_tips false
            show_release_notes false

            keybinds clear-defaults=true {
              normal {
                bind "Ctrl Space" { SwitchToMode "Tmux"; }

                bind "Alt h" "Alt Left" { MoveFocus "Left"; }
                bind "Alt l" "Alt Right" { MoveFocus "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }

                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
                bind "Alt 6" { GoToTab 6; }
                bind "Alt 7" { GoToTab 7; }
                bind "Alt 8" { GoToTab 8; }
                bind "Alt 9" { GoToTab 9; }
                bind "Alt [" { GoToPreviousTab; }
                bind "Alt ]" { GoToNextTab; }

                bind "Alt n" { NewPane; }
                bind "Alt z" { ToggleFocusFullscreen; }
                bind "Alt f" { ToggleFloatingPanes; }
              }

              tmux {
                bind "Esc" { SwitchToMode "Normal"; }

                bind "p" { SwitchToMode "Pane"; }
                bind "t" { SwitchToMode "Tab"; }
                bind "r" { SwitchToMode "Resize"; }
                bind "s" { SwitchToMode "Scroll"; }
                bind "o" { SwitchToMode "Session"; }

                bind "n" { NewPane; SwitchToMode "Normal"; }
                bind "d" { NewPane "Down"; SwitchToMode "Normal"; }
                bind "v" { NewPane "Right"; SwitchToMode "Normal"; }
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "c" { NewTab; SwitchToMode "Normal"; }
              }

              pane {
                bind "Esc" "Enter" { SwitchToMode "Normal"; }
                bind "h" "Left" { MoveFocus "Left"; }
                bind "l" "Right" { MoveFocus "Right"; }
                bind "j" "Down" { MoveFocus "Down"; }
                bind "k" "Up" { MoveFocus "Up"; }
                bind "n" { NewPane; }
                bind "d" { NewPane "Down"; }
                bind "r" { NewPane "Right"; }
                bind "x" { CloseFocus; }
                bind "f" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Normal"; }
              }

              tab {
                bind "Esc" "Enter" { SwitchToMode "Normal"; }
                bind "h" "Left" { GoToPreviousTab; }
                bind "l" "Right" { GoToNextTab; }
                bind "n" { NewTab; SwitchToMode "Normal"; }
                bind "x" { CloseTab; SwitchToMode "Normal"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
              }

              resize {
                bind "Esc" "Enter" { SwitchToMode "Normal"; }
                bind "h" "Left" { Resize "Increase Left"; }
                bind "l" "Right" { Resize "Increase Right"; }
                bind "j" "Down" { Resize "Increase Down"; }
                bind "k" "Up" { Resize "Increase Up"; }
                bind "H" { Resize "Decrease Left"; }
                bind "L" { Resize "Decrease Right"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
              }

              scroll {
                bind "Esc" "Enter" { SwitchToMode "Normal"; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
              }

              session {
                bind "Esc" "Enter" { SwitchToMode "Normal"; }
                bind "d" { Detach; }
              }
            }
          '';
          force = true;
        };

        xdg.configFile."zellij/layouts/default.kdl" = {
          text = ''
            layout {
              swap_tiled_layout name="vertical" {
                tab max_panes=5 {
                  pane split_direction="vertical" {
                    pane
                    pane { children; }
                  }
                }
                tab max_panes=8 {
                  pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                  }
                }
                tab max_panes=12 {
                  pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                    pane { pane; pane; pane; pane; }
                  }
                }
              }

              swap_tiled_layout name="horizontal" {
                tab max_panes=5 {
                  pane
                  pane
                }
                tab max_panes=8 {
                  pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                  }
                }
                tab max_panes=12 {
                  pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                  }
                }
              }

              swap_tiled_layout name="stacked" {
                tab min_panes=5 {
                  pane split_direction="vertical" {
                    pane
                    pane stacked=true { children; }
                  }
                }
              }

              swap_floating_layout name="staggered" {
                floating_panes
              }

              swap_floating_layout name="enlarged" {
                floating_panes max_panes=10 {
                  pane { x "5%"; y 1; width "90%"; height "90%"; }
                  pane { x "5%"; y 2; width "90%"; height "90%"; }
                  pane { x "5%"; y 3; width "90%"; height "90%"; }
                  pane { x "5%"; y 4; width "90%"; height "90%"; }
                  pane { x "5%"; y 5; width "90%"; height "90%"; }
                  pane { x "5%"; y 6; width "90%"; height "90%"; }
                  pane { x "5%"; y 7; width "90%"; height "90%"; }
                  pane { x "5%"; y 8; width "90%"; height "90%"; }
                  pane { x "5%"; y 9; width "90%"; height "90%"; }
                  pane focus=true { x 10; y 10; width "90%"; height "90%"; }
                }
              }

              swap_floating_layout name="spread" {
                floating_panes max_panes=1 {
                  pane { y "50%"; x "50%"; }
                }
                floating_panes max_panes=2 {
                  pane { x "1%"; y "25%"; width "45%"; }
                  pane { x "50%"; y "25%"; width "45%"; }
                }
                floating_panes max_panes=3 {
                  pane focus=true { y "55%"; width "45%"; height "45%"; }
                  pane { x "1%"; y "1%"; width "45%"; }
                  pane { x "50%"; y "1%"; width "45%"; }
                }
                floating_panes max_panes=4 {
                  pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                  pane focus=true { x "50%"; y "55%"; width "45%"; height "45%"; }
                  pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                  pane { x "50%"; y "1%"; width "45%"; height "45%"; }
                }
              }

              default_tab_template {
                pane size=1 borderless=true {
                  plugin location="file://${zjstatusWasm}" {
                    format_left   "{mode} {tabs}"
                    format_center ""
                    format_right  "#[fg=#89b4fa,bold] #[fg=#cdd6f4,bold]{session}"
                    format_space  ""
                    format_hide_on_overlength "true"
                    format_precedence "crl"

                    border_enabled  "false"

                    mode_normal        "#[bg=#a6e3a1,fg=#11111b,bold] NORMAL #[fg=#a6e3a1]█"
                    mode_locked        "#[bg=#6c7086,fg=#11111b,bold] LOCKED  #[fg=#6c7086]█"
                    mode_resize        "#[bg=#f38ba8,fg=#11111b,bold] RESIZE #[fg=#f38ba8]█"
                    mode_pane          "#[bg=#89b4fa,fg=#11111b,bold] PANE #[fg=#89b4fa]█"
                    mode_tab           "#[bg=#b4befe,fg=#11111b,bold] TAB #[fg=#b4befe]█"
                    mode_scroll        "#[bg=#f9e2af,fg=#11111b,bold] SCROLL #[fg=#f9e2af]█"
                    mode_enter_search  "#[bg=#89dceb,fg=#11111b,bold] ENT-SEARCH #[fg=#89dceb]█"
                    mode_search        "#[bg=#89dceb,fg=#11111b,bold] SEARCH #[fg=#89dceb]█"
                    mode_rename_tab    "#[bg=#b4befe,fg=#11111b,bold] RENAME-TAB #[fg=#b4befe]█"
                    mode_rename_pane   "#[bg=#89b4fa,fg=#11111b,bold] RENAME-PANE #[fg=#89b4fa]█"
                    mode_session       "#[bg=#74c7ec,fg=#11111b,bold] SESSION #[fg=#74c7ec]█"
                    mode_move          "#[bg=#f5c2e7,fg=#11111b,bold] MOVE #[fg=#f5c2e7]█"
                    mode_prompt        "#[bg=#89dceb,fg=#11111b,bold] PROMPT #[fg=#89dceb]█"
                    mode_tmux          "#[bg=#fab387,fg=#11111b,bold] TMUX #[fg=#fab387]█"

                    tab_normal              "#[fg=#89b4fa]█#[bg=#89b4fa,fg=#11111b,bold]{index} #[bg=#313244,fg=#89b4fa,bold] {name}{floating_indicator}#[fg=#313244]█"
                    tab_normal_fullscreen   "#[fg=#89b4fa]█#[bg=#89b4fa,fg=#11111b,bold]{index} #[bg=#313244,fg=#89b4fa,bold] {name}{fullscreen_indicator}#[fg=#313244]█"
                    tab_normal_sync         "#[fg=#89b4fa]█#[bg=#89b4fa,fg=#11111b,bold]{index} #[bg=#313244,fg=#89b4fa,bold] {name}{sync_indicator}#[fg=#313244]█"

                    tab_active              "#[fg=#cba6f7]█#[bg=#cba6f7,fg=#11111b,bold]{index} #[bg=#313244,fg=#cba6f7,bold] {name}{floating_indicator}#[fg=#313244]█"
                    tab_active_fullscreen   "#[fg=#cba6f7]█#[bg=#cba6f7,fg=#11111b,bold]{index} #[bg=#313244,fg=#cba6f7,bold] {name}{fullscreen_indicator}#[fg=#313244]█"
                    tab_active_sync         "#[fg=#cba6f7]█#[bg=#cba6f7,fg=#11111b,bold]{index} #[bg=#313244,fg=#cba6f7,bold] {name}{sync_indicator}#[fg=#313244]█"

                    tab_separator           " "

                    tab_sync_indicator       " "
                    tab_fullscreen_indicator " 󰊓"
                    tab_floating_indicator   " 󰹙"
                  }
                }
                children
              }
            }
          '';
          force = true;
        };
      };
    };
}
