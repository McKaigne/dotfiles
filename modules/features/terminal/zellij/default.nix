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
                    color_rosewater "#f5e0dc"
                    color_flamingo  "#f2cdcd"
                    color_pink      "#f5c2e7"
                    color_mauve     "#cba6f7"
                    color_red       "#f38ba8"
                    color_maroon    "#eba0ac"
                    color_peach     "#fab387"
                    color_yellow    "#f9e2af"
                    color_green     "#a6e3a1"
                    color_teal      "#94e2d5"
                    color_sky       "#89dceb"
                    color_sapphire  "#74c7ec"
                    color_blue      "#89b4fa"
                    color_lavender  "#b4befe"
                    color_text      "#cdd6f4"
                    color_subtext1  "#bac2de"
                    color_subtext0  "#a6adc8"
                    color_overlay2  "#9399b2"
                    color_overlay1  "#7f849c"
                    color_overlay0  "#6c7086"
                    color_surface2  "#585b70"
                    color_surface1  "#45475a"
                    color_surface0  "#313244"
                    color_base      "#1e1e2e"
                    color_mantle    "#181825"
                    color_crust     "#11111b"

                    format_left   "#[bg=$surface0,fg=$sapphire]#[bg=$sapphire,fg=$crust,bold] {session} #[bg=$surface0] {mode}#[bg=$surface0] {tabs}"
                    format_center "{notifications}"
                    format_right  "#[bg=$surface0,fg=$flamingo]#[fg=$crust,bg=$flamingo] #[bg=$surface1,fg=$flamingo,bold] {command_user}@{command_host}#[bg=$surface0,fg=$surface1]#[bg=$surface0,fg=$maroon]#[bg=$maroon,fg=$crust]󰃭 #[bg=$surface1,fg=$maroon,bold] {datetime}#[bg=$surface0,fg=$surface1]"
                    format_space  ""
                    format_hide_on_overlength "true"
                    format_precedence "lrc"

                    border_enabled  "false"
                    border_char     "─"
                    border_format   "#[fg=$surface1]{char}"
                    border_position "top"

                    hide_frame_for_single_pane "true"

                    mode_normal         "#[bg=$surface0,fg=$green]#[bg=$green,fg=$crust,bold] #[bg=$surface1,fg=$green,bold] NOR#[bg=$surface0,fg=$surface1]"
                    mode_tmux           "#[bg=$surface0,fg=$mauve]#[bg=$mauve,fg=$crust,bold] #[bg=$surface1,fg=$mauve,bold] MUX#[bg=$surface0,fg=$surface1]"
                    mode_locked         "#[bg=$surface0,fg=$red]#[bg=$red,fg=$crust,bold] #[bg=$surface1,fg=$red,bold] LCK#[bg=$surface0,fg=$surface1]"
                    mode_pane           "#[bg=$surface0,fg=$teal]#[bg=$teal,fg=$crust,bold] #[bg=$surface1,fg=$teal,bold] PAN#[bg=$surface0,fg=$surface1]"
                    mode_tab            "#[bg=$surface0,fg=$teal]#[bg=$teal,fg=$crust,bold] #[bg=$surface1,fg=$teal,bold] TAB#[bg=$surface0,fg=$surface1]"
                    mode_scroll         "#[bg=$surface0,fg=$flamingo]#[bg=$flamingo,fg=$crust,bold] #[bg=$surface1,fg=$flamingo,bold] SCR#[bg=$surface0,fg=$surface1]"
                    mode_enter_search   "#[bg=$surface0,fg=$flamingo]#[bg=$flamingo,fg=$crust,bold] #[bg=$surface1,fg=$flamingo,bold] ENS#[bg=$surface0,fg=$surface1]"
                    mode_search         "#[bg=$surface0,fg=$flamingo]#[bg=$flamingo,fg=$crust,bold] #[bg=$surface1,fg=$flamingo,bold] SRC#[bg=$surface0,fg=$surface1]"
                    mode_resize         "#[bg=$surface0,fg=$yellow]#[bg=$yellow,fg=$crust,bold] #[bg=$surface1,fg=$yellow,bold] RES#[bg=$surface0,fg=$surface1]"
                    mode_rename_tab     "#[bg=$surface0,fg=$yellow]#[bg=$yellow,fg=$crust,bold] #[bg=$surface1,fg=$yellow,bold] RNT#[bg=$surface0,fg=$surface1]"
                    mode_rename_pane    "#[bg=$surface0,fg=$yellow]#[bg=$yellow,fg=$crust,bold] #[bg=$surface1,fg=$yellow,bold] RNP#[bg=$surface0,fg=$surface1]"
                    mode_move           "#[bg=$surface0,fg=$yellow]#[bg=$yellow,fg=$crust,bold] #[bg=$surface1,fg=$yellow,bold] MOV#[bg=$surface0,fg=$surface1]"
                    mode_session        "#[bg=$surface0,fg=$pink]#[bg=$pink,fg=$crust,bold] #[bg=$surface1,fg=$pink,bold] SES#[bg=$surface0,fg=$surface1]"
                    mode_prompt         "#[bg=$surface0,fg=$pink]#[bg=$pink,fg=$crust,bold] #[bg=$surface1,fg=$pink,bold] PRM#[bg=$surface0,fg=$surface1]"

                    tab_normal              "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
                    tab_normal_fullscreen   "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
                    tab_normal_sync         "#[bg=$surface0,fg=$blue]#[bg=$blue,fg=$crust,bold]{index} #[bg=$surface1,fg=$blue,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"

                    tab_active              "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{floating_indicator}#[bg=$surface0,fg=$surface1]"
                    tab_active_fullscreen   "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{fullscreen_indicator}#[bg=$surface0,fg=$surface1]"
                    tab_active_sync         "#[bg=$surface0,fg=$peach]#[bg=$peach,fg=$crust,bold]{index} #[bg=$surface1,fg=$peach,bold] {name}{sync_indicator}#[bg=$surface0,fg=$surface1]"

                    tab_separator           "#[bg=$surface0] "

                    tab_sync_indicator       " "
                    tab_fullscreen_indicator " 󰊓"
                    tab_floating_indicator   " 󰹙"

                    notification_format_unread "#[bg=$surface0,fg=$yellow]#[bg=$yellow,fg=$crust] #[bg=$surface1,fg=$yellow] {message}#[bg=$surface0,fg=$yellow]"
                    notification_format_no_notifications ""
                    notification_show_interval "10"

                    command_host_command    "uname -n"
                    command_host_format     "{stdout}"
                    command_host_interval   "0"
                    command_host_rendermode "static"

                    command_user_command    "whoami"
                    command_user_format     "{stdout}"
                    command_user_interval   "10"
                    command_user_rendermode "static"

                    datetime          "{format}"
                    datetime_format   "%Y-%m-%d 󰅐 %H:%M"
                    datetime_timezone "Asia/Manila"
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
