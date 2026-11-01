_: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      zjstatusWasm = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
        sha256 = "282ceab219e56e1908c9fac33907241fe6c3e1ef7d85faab3e5f438cef87b8fe";
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
    ReadCliPipes
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
                hide_session_name true
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

                ribbon_selected {
                  base "#cba6f7"
                  background "#1e1e2e"
                  emphasis_0 "#cba6f7"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
                ribbon_unselected {
                  base "#cba6f7"
                  background "#1e1e2e"
                  emphasis_0 "#cba6f7"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
                text_unselected {
                  base "#cdd6f4"
                  background "#1e1e2e"
                  emphasis_0 "#fab387"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }
                text_selected {
                  base "#cdd6f4"
                  background "#1e1e2e"
                  emphasis_0 "#fab387"
                  emphasis_1 "#a6e3a1"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#f38ba8"
                }

                frame_selected {
                  base "#cba6f7"
                  background "#1e1e2e"
                  emphasis_0 "#cba6f7"
                  emphasis_1 "#b4befe"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#a6e3a1"
                }
                frame_highlight {
                  base "#cba6f7"
                  background "#1e1e2e"
                  emphasis_0 "#cba6f7"
                  emphasis_1 "#b4befe"
                  emphasis_2 "#89b4fa"
                  emphasis_3 "#a6e3a1"
                }
                frame_unselected {
                  base "#45475a"
                  background "#1e1e2e"
                  emphasis_0 "#6c7086"
                  emphasis_1 "#585b70"
                  emphasis_2 "#45475a"
                  emphasis_3 "#313244"
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
                bind "z" { ToggleFocusFullscreen; SwitchToMode "Locked"; }
                bind "w" { ToggleFloatingPanes; SwitchToMode "Locked"; }
                bind "e" { TogglePaneEmbedOrFloating; SwitchToMode "Locked"; }

                // Plugins
                bind "y" {
                  LaunchOrFocusPlugin "file://${harpoonWasm}" {
                    floating true
                    move_to_focused_tab true
                  };
                  SwitchToMode "Locked";
                }
                bind "f" {
                  LaunchOrFocusPlugin "file://${monocleWasm}" {
                    floating true
                  };
                  SwitchToMode "Locked";
                }
                bind "F" {
                  LaunchPlugin "file://${monocleWasm}" {
                    in_place true
                    kiosk true
                  };
                  SwitchToMode "Locked";
                }

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
                    format_left   "#[bg=#cba6f7] #[default] {session}  {tabs}"
                    format_center ""
                    format_right  "{mode} "
                    format_space  ""

                    border_enabled "false"
                    border_char "─"
                    border_format "#[fg=#45475a]{char}"
                    border_position "top"
                    hide_frame_for_single_pane "false"

                    mode_locked       "#[fg=#cba6f7]C-SPC #[fg=#6c7086,italic]󰌿 unlock"
                    mode_normal       "#[fg=#cba6f7]h/j/k/l #[fg=#6c7086,italic]󰆍 focus #[fg=#cba6f7]s/v #[fg=#6c7086,italic]󰤼 split #[fg=#cba6f7]f #[fg=#6c7086,italic]󰈞 files #[fg=#cba6f7]y #[fg=#6c7086,italic]󰛢 mark #[fg=#cba6f7]p #[fg=#6c7086,italic]󰆍 pane #[fg=#cba6f7]t #[fg=#6c7086,italic]󰓩 tab #[fg=#cba6f7]r #[fg=#6c7086,italic]󰩨 resize #[fg=#cba6f7]m #[fg=#6c7086,italic] move #[fg=#cba6f7]s #[fg=#6c7086,italic]󰞘 scroll #[fg=#cba6f7]o #[fg=#6c7086,italic]󱂬 session #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 lock"
                    mode_move         "#[fg=#cba6f7]h/j/k/l #[fg=#6c7086,italic] move #[fg=#cba6f7]n/p #[fg=#6c7086,italic]󰒭 reorder #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_pane         "#[fg=#cba6f7]h/j/k/l #[fg=#6c7086,italic]󰒋 focus #[fg=#cba6f7]s/v #[fg=#6c7086,italic]󰤼 split #[fg=#cba6f7]x #[fg=#6c7086,italic]󰅖 close #[fg=#cba6f7]z #[fg=#6c7086,italic]󰊓 zoom #[fg=#cba6f7]w #[fg=#6c7086,italic]󰉈 float #[fg=#cba6f7]c #[fg=#6c7086,italic]󰑕 rename #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_tab          "#[fg=#cba6f7]h/l #[fg=#6c7086,italic]󰓩 switch #[fg=#cba6f7]1-9 #[fg=#6c7086,italic]󰒭 jump #[fg=#cba6f7]n #[fg=#6c7086,italic]󰐕 new #[fg=#cba6f7]x #[fg=#6c7086,italic]󰅖 close #[fg=#cba6f7]r #[fg=#6c7086,italic]󰑕 rename #[fg=#cba6f7]s #[fg=#6c7086,italic]󰓦 sync #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_resize       "#[fg=#cba6f7]h/j/k/l #[fg=#6c7086,italic]󰩨 resize #[fg=#cba6f7]+/- #[fg=#6c7086,italic]󰩬 scale #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_scroll       "#[fg=#cba6f7]j/k #[fg=#6c7086,italic]󰞘 scroll #[fg=#cba6f7]d/u #[fg=#6c7086,italic]󱕑 half-page #[fg=#cba6f7]/ #[fg=#6c7086,italic]󰍉 search #[fg=#cba6f7]e #[fg=#6c7086,italic]󰷈 edit #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_search       "#[fg=#cba6f7]n/N #[fg=#6c7086,italic]󰍉 next/prev #[fg=#cba6f7]c #[fg=#6c7086,italic]󰬲 case #[fg=#cba6f7]w #[fg=#6c7086,italic]󰑐 wrap #[fg=#cba6f7]o #[fg=#6c7086,italic]󰬵 word #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_entersearch  "#[fg=#cba6f7]Enter #[fg=#6c7086,italic]󰍉 search #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰅖 cancel"
                    mode_renametab    "#[fg=#cba6f7]Enter #[fg=#6c7086,italic]󰑕 submit #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰅖 cancel"
                    mode_renamepane   "#[fg=#cba6f7]Enter #[fg=#6c7086,italic]󰑕 submit #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰅖 cancel"
                    mode_session      "#[fg=#cba6f7]d #[fg=#6c7086,italic]󰈆 detach #[fg=#cba6f7]w #[fg=#6c7086,italic]󰀻 manager #[fg=#cba6f7]q #[fg=#6c7086,italic]󰗼 quit #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 done"
                    mode_tmux         "#[fg=#cba6f7]C-SPC #[fg=#6c7086,italic]󰌌 tmux #[fg=#cba6f7]Esc #[fg=#6c7086,italic]󰌾 lock"

                    tab_sync_indicator       "󰓦"
                    tab_fullscreen_indicator "󰊓"
                    tab_floating_indicator   "󰉈"
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
