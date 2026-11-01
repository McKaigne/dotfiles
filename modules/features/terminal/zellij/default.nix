_: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      zjstatusWasm = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
        sha256 = "282ceab219e56e1908c9fac33907241fe6c3e1ef7d85faab3e5f438cef87b8fe";
      };
      zjstatusHintsWasm = pkgs.fetchurl {
        url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
        sha256 = "936c55e9025c0edbd43421383efc151bdfdc78e924f966bfe9e7c682bec8719d";
      };
      monocleWasm = pkgs.fetchurl {
        url = "https://github.com/imsnif/monocle/releases/download/v0.100.2/monocle.wasm";
        sha256 = "4cb7e2cc912d975b4e755c93e44e7f0de62ef9240a09a89b735490cf4713792c";
      };
      harpoonWasm = pkgs.fetchurl {
        url = "https://github.com/Nacho114/harpoon/releases/download/v0.3.0/harpoon.wasm";
        sha256 = "7f8cf57a71f1dbbbd115337a31638780d7e18e9b876def1c81c970188caa32f2";
      };

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
EOF
fi
if ! grep -Fq "${zjstatusHintsWasm}" "$HOME/.cache/zellij/permissions.kdl" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.cache/zellij/permissions.kdl"
"${zjstatusHintsWasm}" {
    ReadApplicationState
    ChangeApplicationState
}
EOF
fi
if ! grep -Fq "${monocleWasm}" "$HOME/.cache/zellij/permissions.kdl" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.cache/zellij/permissions.kdl"
"${monocleWasm}" {
    ReadApplicationState
    ChangeApplicationState
    RunCommands
    ChangeFocusedPane
    OpenNewPane
}
EOF
fi
if ! grep -Fq "${harpoonWasm}" "$HOME/.cache/zellij/permissions.kdl" 2>/dev/null; then
  cat << 'EOF' >> "$HOME/.cache/zellij/permissions.kdl"
"${harpoonWasm}" {
    ReadApplicationState
    ChangeApplicationState
    ChangeFocusedPane
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
      ];

      home-manager.users.${user} = {
        programs.zellij = {
          enable = true;
          package = zellijWrapped;
        };

        xdg.configFile."zellij/config.kdl" = {
          text = ''
            default_shell "fish"
            default_mode "locked"
            scroll_buffer_size 10000
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
            pane_frames true
            theme "catppuccin-mocha"

            ui {
              pane_frames {
                rounded_corners true
                hide_session_name false
              }
            }

            themes {
              catppuccin-mocha {
                bg "#1e1e2e"
                fg "#cdd6f4"
                red "#f38ba8"
                green "#a6e3a1"
                blue "#89b4fa"
                yellow "#f9e2af"
                magenta "#cba6f7"
                orange "#fab387"
                cyan "#94e2d5"
                black "#181825"
                white "#cdd6f4"

                frame_selected {
                  base "#cba6f7"
                  background "#1e1e2e"
                  emphasis_0 "#fab387"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
                frame_unselected {
                  base "#45475a"
                  background "#1e1e2e"
                  emphasis_0 "#fab387"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
                frame_highlight {
                  base "#fab387"
                  background "#1e1e2e"
                  emphasis_0 "#cba6f7"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
              }
            }

            advanced_mouse_actions false
            mouse_hover_effects false
            copy_on_select true
            show_startup_tips false
            show_release_notes false
            session_serialization true
            pane_viewport_serialization true
            scrollback_lines_to_serialize 500
            serialization_interval 60

            plugins {
              zjstatus-hints location="file://${zjstatusHintsWasm}" {
                max_length 0
                overflow_str "..."
                pipe_name "zjstatus_hints"
                hide_in_base_mode true
              }
            }

            load_plugins {
              zjstatus-hints
            }

            keybinds clear-defaults=true {
              locked {
                bind "Ctrl space" { SwitchToMode "Normal"; }
              }

              shared_except "locked" {
                bind "Ctrl space" { SwitchToMode "Locked"; }

                // Harpoon on Alt+y
                bind "Alt y" {
                  LaunchOrFocusPlugin "file://${harpoonWasm}" {
                    floating true
                    move_to_focused_tab true
                  };
                }

                // Monocle on Alt+m (new floating pane)
                bind "Alt m" {
                  LaunchOrFocusPlugin "file://${monocleWasm}" {
                    floating true
                  };
                }

                // Monocle on Alt+Shift+m (in-place on current pane)
                bind "Alt M" {
                  LaunchPlugin "file://${monocleWasm}" {
                    in_place true
                    kiosk true
                  };
                }
              }

              shared_except "locked" "entersearch" "renametab" "renamepane" {
                bind "Esc" { SwitchToMode "Locked"; }
              }

              shared_except "locked" "entersearch" {
                bind "Enter" { SwitchToMode "Locked"; }
              }

              normal {
                bind "h" "Left" { MoveFocus "Left"; }
                bind "j" "Down" { MoveFocus "Down"; }
                bind "k" "Up" { MoveFocus "Up"; }
                bind "l" "Right" { MoveFocus "Right"; }

                bind "s" { NewPane "Down"; SwitchToMode "Locked"; }
                bind "v" { NewPane "Right"; SwitchToMode "Locked"; }
                bind "n" { NewPane; SwitchToMode "Locked"; }
                bind "x" { CloseFocus; SwitchToMode "Locked"; }
                bind "f" "z" { ToggleFocusFullscreen; SwitchToMode "Locked"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Locked"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Locked"; }

                bind "p" { SwitchToMode "Pane"; }
                bind "t" { SwitchToMode "Tab"; }
                bind "r" { SwitchToMode "Resize"; }
                bind "m" { SwitchToMode "Move"; }
                bind "o" { SwitchToMode "Session"; }

                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "u" { HalfPageScrollUp; SwitchToMode "Scroll"; }
                bind "d" { HalfPageScrollDown; SwitchToMode "Scroll"; }

                bind "1" { GoToTab 1; SwitchToMode "Locked"; }
                bind "2" { GoToTab 2; SwitchToMode "Locked"; }
                bind "3" { GoToTab 3; SwitchToMode "Locked"; }
                bind "4" { GoToTab 4; SwitchToMode "Locked"; }
                bind "5" { GoToTab 5; SwitchToMode "Locked"; }
                bind "6" { GoToTab 6; SwitchToMode "Locked"; }
                bind "7" { GoToTab 7; SwitchToMode "Locked"; }
                bind "8" { GoToTab 8; SwitchToMode "Locked"; }
                bind "9" { GoToTab 9; SwitchToMode "Locked"; }
                bind "0" { GoToTab 10; SwitchToMode "Locked"; }

                bind "[" { GoToPreviousTab; }
                bind "]" { GoToNextTab; }
                bind "Tab" { ToggleTab; }

                bind "=" "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }

                bind "D" { Detach; }
                bind "q" { Quit; }
              }

              pane {
                bind "h" "Left" { MoveFocus "Left"; }
                bind "j" "Down" { MoveFocus "Down"; }
                bind "k" "Up" { MoveFocus "Up"; }
                bind "l" "Right" { MoveFocus "Right"; }

                bind "s" { NewPane "Down"; SwitchToMode "Locked"; }
                bind "v" "r" { NewPane "Right"; SwitchToMode "Locked"; }
                bind "n" { NewPane; SwitchToMode "Locked"; }
                bind "d" { NewPane "stacked"; SwitchToMode "Locked"; }
                bind "x" { CloseFocus; SwitchToMode "Locked"; }
                bind "f" "z" { ToggleFocusFullscreen; SwitchToMode "Locked"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Locked"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Locked"; }
                bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
                bind "i" { TogglePanePinned; SwitchToMode "Locked"; }
                bind "Tab" { SwitchFocus; }
                bind "p" { SwitchToMode "Normal"; }
              }

              tab {
                bind "h" "Left" "k" "Up" { GoToPreviousTab; }
                bind "l" "Right" "j" "Down" { GoToNextTab; }
                bind "n" { NewTab; SwitchToMode "Locked"; }
                bind "x" { CloseTab; SwitchToMode "Locked"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "Locked"; }
                bind "b" { BreakPane; SwitchToMode "Locked"; }
                bind "]" { BreakPaneRight; SwitchToMode "Locked"; }
                bind "[" { BreakPaneLeft; SwitchToMode "Locked"; }
                bind "1" { GoToTab 1; SwitchToMode "Locked"; }
                bind "2" { GoToTab 2; SwitchToMode "Locked"; }
                bind "3" { GoToTab 3; SwitchToMode "Locked"; }
                bind "4" { GoToTab 4; SwitchToMode "Locked"; }
                bind "5" { GoToTab 5; SwitchToMode "Locked"; }
                bind "6" { GoToTab 6; SwitchToMode "Locked"; }
                bind "7" { GoToTab 7; SwitchToMode "Locked"; }
                bind "8" { GoToTab 8; SwitchToMode "Locked"; }
                bind "9" { GoToTab 9; SwitchToMode "Locked"; }
                bind "0" { GoToTab 10; SwitchToMode "Locked"; }
                bind "Tab" { ToggleTab; }
                bind "t" { SwitchToMode "Normal"; }
              }

              resize {
                bind "h" "Left" { Resize "Increase Left"; }
                bind "j" "Down" { Resize "Increase Down"; }
                bind "k" "Up" { Resize "Increase Up"; }
                bind "l" "Right" { Resize "Increase Right"; }
                bind "H" { Resize "Decrease Left"; }
                bind "J" { Resize "Decrease Down"; }
                bind "K" { Resize "Decrease Up"; }
                bind "L" { Resize "Decrease Right"; }
                bind "=" "+" { Resize "Increase"; }
                bind "-" { Resize "Decrease"; }
                bind "r" { SwitchToMode "Normal"; }
              }

              move {
                bind "h" "Left" { MovePane "Left"; }
                bind "j" "Down" { MovePane "Down"; }
                bind "k" "Up" { MovePane "Up"; }
                bind "l" "Right" { MovePane "Right"; }
                bind "n" "Tab" { MovePane; }
                bind "p" { MovePaneBackwards; }
                bind "m" { SwitchToMode "Normal"; }
              }

              scroll {
                bind "e" { EditScrollback { ansi true; }; SwitchToMode "Locked"; }
                bind "s" "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Locked"; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" { PageScrollDown; }
                bind "Ctrl b" "PageUp" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "G" { ScrollToBottom; SwitchToMode "Locked"; }
                bind "g" { ScrollToTop; }
              }

              entersearch {
                bind "Esc" "Ctrl c" { SwitchToMode "Scroll"; }
                bind "Enter" { SwitchToMode "Search"; }
              }

              search {
                bind "Ctrl c" { ScrollToBottom; SwitchToMode "Locked"; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl f" "PageDown" { PageScrollDown; }
                bind "Ctrl b" "PageUp" { PageScrollUp; }
                bind "d" { HalfPageScrollDown; }
                bind "u" { HalfPageScrollUp; }
                bind "n" { Search "down"; }
                bind "p" "N" { Search "up"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "o" { SearchToggleOption "WholeWord"; }
              }

              session {
                bind "d" { Detach; }
                bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                  };
                  SwitchToMode "Locked";
                }
                bind "q" { Quit; }
                bind "o" { SwitchToMode "Normal"; }
              }

              renametab {
                bind "Enter" { SwitchToMode "Locked"; }
                bind "Esc" "Ctrl c" { UndoRenameTab; SwitchToMode "Locked"; }
              }

              renamepane {
                bind "Enter" { SwitchToMode "Locked"; }
                bind "Esc" "Ctrl c" { UndoRenamePane; SwitchToMode "Locked"; }
              }
            }
          '';
          force = true;
        };

        xdg.configFile."zellij/layouts/default.kdl" = {
          text = ''
            layout {
              default_tab_template {
                children
                pane size=1 borderless=true {
                  plugin location="file://${zjstatusWasm}" {
                    format_left   "{mode} {session} {tabs}"
                    format_center ""
                    format_right  "{pipe_zjstatus_hints}"
                    format_space  ""
                    pipe_zjstatus_hints_format "{output}"

                    border_enabled "false"
                    border_char "─"
                    border_format "#[fg=#45475a]{char}"
                    border_position "top"
                    hide_frame_for_single_pane "false"

                    mode_locked      "#[bg=#f38ba8,bold] "
                    mode_normal      "#[bg=#cba6f7,bold] "
                    mode_resize      "#[bg=#fab387,bold] "
                    mode_pane        "#[bg=#a6e3a1,bold] "
                    mode_move        "#[bg=#f9e2af,bold] "
                    mode_tab         "#[bg=#89dceb,bold] "
                    mode_scroll      "#[bg=#f2cdcd,bold] "
                    mode_search      "#[bg=#89b4fa,bold] "
                    mode_entersearch "#[bg=#74c7ec,bold] "
                    mode_renametab   "#[bg=#94e2d5,bold] "
                    mode_renamepane  "#[bg=#a6e3a1,bold] "
                    mode_session     "#[bg=#f5c2e7,bold] "
                    mode_tmux        "#[bg=#b4befe,bold] "

                    tab_sync_indicator       "󰓦"
                    tab_fullscreen_indicator "󰊓"
                    tab_floating_indicator   "⬚"
                    tab_separator          " "

                    tab_normal              "#[fg=#cdd6f4]{name}  "
                    tab_normal_fullscreen   "#[fg=#cdd6f4]{fullscreen_indicator}{name}  "
                    tab_normal_sync         "#[fg=#a6e3a1,bold,italic]{sync_indicator}#[fg=#cdd6f4]{name}  "
                    tab_active              "#[fg=#cba6f7,bold,italic]{name}  "
                    tab_active_fullscreen   "#[fg=#cba6f7,bold,italic]{fullscreen_indicator}{name}  "
                    tab_active_sync         "#[fg=#a6e3a1,bold,italic]{sync_indicator}#[fg=#cba6f7,bold,italic]{name}  "
                  }
                }
              }

              swap_tiled_layout name="vertical" {
                tab {
                  pane split_direction="vertical" {
                    children
                  }
                }
              }

              swap_tiled_layout name="horizontal" {
                tab {
                  pane split_direction="horizontal" {
                    children
                  }
                }
              }

              swap_tiled_layout name="stacked" {
                tab {
                  pane stacked=true {
                    children
                  }
                }
              }
            }
          '';
          force = true;
        };
      };
    };
}
