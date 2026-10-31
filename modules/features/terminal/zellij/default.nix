_: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      homeDir = config.home-manager.users.${user}.home.homeDirectory;
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
"https://github.com/dj95/zjstatus/releases/latest/download/zjstatus.wasm" {
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

        xdg.configFile."zellij/scripts/system_usage.sh" = {
          text = ''
            #!/usr/bin/env sh
            load=$(awk '{print $1}' /proc/loadavg)
            mem=$(free -m 2>/dev/null | awk '/Mem:/ { printf("%.0f%%", $3/$2*100) }')
            printf '#[fg=#cba6f7] %s #[fg=#89b4fa] %s
' "$load" "$mem"
          '';
          executable = true;
        };

        xdg.configFile."zellij/config.kdl" = {
          text = ''
            default_shell "fish"
            scroll_buffer_size 10000
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"

            ui {
              pane_frames {
                rounded_corners true
              }
            }

            advanced_mouse_actions false
            mouse_hover_effects false
            copy_on_select true
            show_startup_tips false
            show_release_notes false
            session_serialization true
            pane_viewport_serialization true
            scrollback_lines_to_serialize 0
            serialization_interval 60

            plugins {
              zjstatus-bar location="file://${zjstatusWasm}" {
                color_dark    "#181825"
                color_red     "#f38ba8"
                color_blue    "#89b4fa"
                color_green   "#a6e3a1"
                color_mauve   "#cba6f7"
                color_default "#cdd6f4"

                format_left   "{mode} #[fg=$default,bold]{session}   {tabs}"
                format_center ""
                format_right  "{command_usage}"
                format_space  ""

                mode_normal        "#[bg=$mauve] "
                mode_tmux          "#[bg=$mauve] "
                mode_tab           "#[fg=$dark,bg=$mauve,bold][TAB]"
                mode_rename_pane   "#[fg=$dark,bg=$mauve,bold][RENAMEPANE]"
                mode_rename_tab    "#[fg=$dark,bg=$mauve,bold][RENAMETAB]"
                mode_resize        "#[fg=$dark,bg=$mauve,bold][RESIZE]"
                mode_scroll        "#[fg=$dark,bg=$mauve,bold][SCROLL]"
                mode_enter_search  "#[fg=$dark,bg=$mauve,bold][ENTERSEARCH]"
                mode_search        "#[fg=$dark,bg=$mauve,bold][SEARCH]"

                tab_sync_indicator       "S"
                tab_fullscreen_indicator "󰊓"
                tab_floating_indicator   "⬚"
                tab_normal               "#[fg=$default]{name}  "
                tab_normal_fullscreen  "#[fg=$default]{fullscreen_indicator}{name}  "
                tab_normal_sync        "#[fg=$green,bold,italic]{sync_indicator}#[fg=$default]{name}  "
                tab_active             "#[fg=$mauve,bold,italic]{name}  "
                tab_active_fullscreen  "#[fg=$mauve,bold,italic]{fullscreen_indicator}{name}  "
                tab_active_sync        "#[fg=$green,bold,italic]{sync_indicator}#[fg=$mauve,bold,italic]{name}  "

                command_usage_command    "${homeDir}/.config/zellij/scripts/system_usage.sh"
                command_usage_format     "{stdout}"
                command_usage_rendermode "dynamic"
                command_usage_interval   "2"
              }
            }

            keybinds clear-defaults=true {
              normal {
                bind "Ctrl a" { SwitchToMode "Tmux"; }
              }

              tmux {
                bind "Esc" "q" "Ctrl c" { SwitchToMode "Normal"; }
                bind "Ctrl a" { Write 1; SwitchToMode "Normal"; }

                bind "h" { MoveFocus "Left"; SwitchToMode "Normal"; }
                bind "Shift h" { MovePane "Left"; SwitchToMode "Normal"; }
                bind "l" { MoveFocus "Right"; SwitchToMode "Normal"; }
                bind "Shift l" { MovePane "Right"; SwitchToMode "Normal"; }
                bind "k" { MoveFocus "Up"; SwitchToMode "Normal"; }
                bind "Shift k" { MovePane "Up"; SwitchToMode "Normal"; }
                bind "j" { MoveFocus "Down"; SwitchToMode "Normal"; }
                bind "Shift j" { MovePane "Down"; SwitchToMode "Normal"; }

                bind "b" {
                  Run "nnn" {
                    direction "Right"
                  };
                  SwitchToMode "Normal";
                }
                bind "v" {
                  Run "nnn" {
                    direction "Down"
                  };
                  SwitchToMode "Normal";
                }

                bind "n" { NewPane "stacked"; SwitchToMode "Normal"; }
                bind "x" { CloseFocus; SwitchToMode "Normal"; }
                bind "z" { ToggleFocusFullscreen; SwitchToMode "Normal"; }
                bind "o" { NewPane; SwitchToMode "Normal"; }
                bind "Shift r" { SwitchToMode "RenamePane"; PaneNameInput 0; }
                bind "g" { NextSwapLayout; SwitchToMode "Normal"; }
                bind "." { ToggleFloatingPanes; SwitchToMode "Normal"; }
                bind ">" { TogglePaneEmbedOrFloating; SwitchToMode "Normal"; }
                bind "Ctrl r" { SwitchToMode "Resize"; }

                bind "a" { ToggleTab; SwitchToMode "Normal"; }
                bind "t" { NewTab; SwitchToMode "Normal"; }
                bind "Ctrl t" { SwitchToMode "Tab"; }
                bind "1" { GoToTab 1; SwitchToMode "Normal"; }
                bind "2" { GoToTab 2; SwitchToMode "Normal"; }
                bind "3" { GoToTab 3; SwitchToMode "Normal"; }
                bind "4" { GoToTab 4; SwitchToMode "Normal"; }
                bind "5" { GoToTab 5; SwitchToMode "Normal"; }
                bind "6" { GoToTab 6; SwitchToMode "Normal"; }
                bind "7" { GoToTab 7; SwitchToMode "Normal"; }
                bind "8" { GoToTab 8; SwitchToMode "Normal"; }
                bind "9" { GoToTab 9; SwitchToMode "Normal"; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "Shift x" { CloseTab; SwitchToMode "Normal"; }

                bind "Ctrl l" { Clear; SwitchToMode "Normal"; }
                bind "s" "f" { EditScrollback { ansi true; }; SwitchToMode "Normal"; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "Ctrl d" "d" { SwitchToMode "Scroll"; }

                bind "w" {
                  LaunchOrFocusPlugin "session-manager" {
                    floating true
                    move_to_focused_tab true
                  };
                  SwitchToMode "Normal";
                }
                bind "p" {
                  LaunchOrFocusPlugin "zellij:plugin-manager" {
                    floating true
                    move_to_focused_tab true
                  };
                  SwitchToMode "Normal";
                }
              }

              renamepane {
                bind "Enter" { SwitchToMode "Normal"; }
                bind "Ctrl a" "Esc" "Ctrl c" { UndoRenamePane; SwitchToMode "Normal"; }
              }

              resize {
                bind "Ctrl a" "q" "Esc" "Ctrl c" "Ctrl r" { SwitchToMode "Normal"; }
                bind "h" "Left" { Resize "Increase Left"; }
                bind "j" "Down" { Resize "Increase Down"; }
                bind "k" "Up" { Resize "Increase Up"; }
                bind "l" "Right" { Resize "Increase Right"; }
              }

              tab {
                bind "Ctrl a" "Enter" "Esc" "q" "Ctrl c" { SwitchToMode "Normal"; }
                bind "h" "Left" "Up" "k" { GoToPreviousTab; }
                bind "Shift h" { MoveTab "Left"; }
                bind "l" "Right" "Down" "j" { GoToNextTab; }
                bind "Shift l" { MoveTab "Right"; }
                bind "x" { CloseTab; }
                bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
                bind "s" { ToggleActiveSyncTab; SwitchToMode "Normal"; }
              }

              renametab {
                bind "Enter" { SwitchToMode "Normal"; }
                bind "Ctrl a" "Esc" "Ctrl c" { UndoRenameTab; SwitchToMode "Normal"; }
              }

              scroll {
                bind "Ctrl a" "q" "Esc" "Ctrl c" { SwitchToMode "Normal"; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "j" "Ctrl e" "Down" { ScrollDown; }
                bind "k" "Ctrl y" "Up" { ScrollUp; }
                bind "Ctrl d" { HalfPageScrollDown; }
                bind "Ctrl u" { HalfPageScrollUp; }
                bind "Ctrl f" { PageScrollDown; }
                bind "Ctrl b" { PageScrollUp; }
                bind "G" { ScrollToBottom; }
                bind "g" { ScrollToTop; }
                bind "s" "f" { EditScrollback { ansi true; }; SwitchToMode "Normal"; }
              }

              entersearch {
                bind "Esc" "Ctrl c" { SwitchToMode "Scroll"; }
                bind "Ctrl a" { SwitchToMode "Normal"; }
                bind "Enter" { SwitchToMode "Search"; }
              }

              search {
                bind "Ctrl a" "Ctrl c" "q" "Esc" { SwitchToMode "Normal"; }
                bind "n" { Search "up"; }
                bind "N" { Search "down"; }
                bind "c" { SearchToggleOption "CaseSensitivity"; }
                bind "w" { SearchToggleOption "Wrap"; }
                bind "o" { SearchToggleOption "WholeWord"; }
                bind "/" { SwitchToMode "EnterSearch"; SearchInput 0; }
                bind "j" "Down" { ScrollDown; }
                bind "k" "Up" { ScrollUp; }
                bind "Ctrl d" { HalfPageScrollDown; }
                bind "Ctrl u" { HalfPageScrollUp; }
                bind "Ctrl f" { PageScrollDown; }
                bind "Ctrl b" { PageScrollUp; }
                bind "G" { ScrollToBottom; }
                bind "g" { ScrollToTop; }
                bind "s" "f" { EditScrollback { ansi true; }; SwitchToMode "Normal"; }
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
                    color_dark    "#181825"
                    color_red     "#f38ba8"
                    color_blue    "#89b4fa"
                    color_green   "#a6e3a1"
                    color_mauve   "#cba6f7"
                    color_default "#cdd6f4"

                    format_left   "{mode} #[fg=$default,bold]{session}   {tabs}"
                    format_center ""
                    format_right  "{command_usage}"
                    format_space  ""

                    mode_normal        "#[bg=$mauve] "
                    mode_tmux          "#[bg=$mauve] "
                    mode_tab           "#[fg=$dark,bg=$mauve,bold][TAB]"
                    mode_rename_pane   "#[fg=$dark,bg=$mauve,bold][RENAMEPANE]"
                    mode_rename_tab    "#[fg=$dark,bg=$mauve,bold][RENAMETAB]"
                    mode_resize        "#[fg=$dark,bg=$mauve,bold][RESIZE]"
                    mode_scroll        "#[fg=$dark,bg=$mauve,bold][SCROLL]"
                    mode_enter_search  "#[fg=$dark,bg=$mauve,bold][ENTERSEARCH]"
                    mode_search        "#[fg=$dark,bg=$mauve,bold][SEARCH]"

                    tab_sync_indicator       "S"
                    tab_fullscreen_indicator "󰊓"
                    tab_floating_indicator   "⬚"
                    tab_normal               "#[fg=$default]{name}  "
                    tab_normal_fullscreen  "#[fg=$default]{fullscreen_indicator}{name}  "
                    tab_normal_sync        "#[fg=$green,bold,italic]{sync_indicator}#[fg=$default]{name}  "
                    tab_active             "#[fg=$mauve,bold,italic]{name}  "
                    tab_active_fullscreen  "#[fg=$mauve,bold,italic]{fullscreen_indicator}{name}  "
                    tab_active_sync        "#[fg=$green,bold,italic]{sync_indicator}#[fg=$mauve,bold,italic]{name}  "

                    command_usage_command    "${homeDir}/.config/zellij/scripts/system_usage.sh"
                    command_usage_format     "{stdout}"
                    command_usage_rendermode "dynamic"
                    command_usage_interval   "2"
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
