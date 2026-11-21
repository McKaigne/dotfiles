{
  flake.modules.homeManager.zellij = {
    config,
    lib,
    pkgs,
    ...
  }: let
    zjstatusWasm = pkgs.fetchurl {
      url = "https://github.com/dj95/zjstatus/releases/download/v0.25.0/zjstatus.wasm";
      sha256 = "282ceab219e56e1908c9fac33907241fe6c3e1ef7d85faab3e5f438cef87b8fe";
    };

    zellijWrapped = pkgs.symlinkJoin {
      name = "zellij-${pkgs.zellij.version}";
      version = pkgs.zellij.version;
      paths = [pkgs.zellij];
      postBuild = ''
        rm -f $out/bin/zellij
        cat << 'WRAPPER' > $out/bin/zellij
        #!/usr/bin/env sh
        ${pkgs.coreutils}/bin/mkdir -p "$HOME/.cache/zellij"
        if ! ${pkgs.gnugrep}/bin/grep -Fq "${zjstatusWasm}" "$HOME/.cache/zellij/permissions.kdl" 2>/dev/null; then
          ${pkgs.coreutils}/bin/cat << 'EOF' >> "$HOME/.cache/zellij/permissions.kdl"
        "${zjstatusWasm}" {
            ReadApplicationState
            ChangeApplicationState
            RunCommands
            ReadCliPipes
        }
        EOF
        fi
        exec ${pkgs.zellij}/bin/zellij "$@"
        WRAPPER
        chmod +x $out/bin/zellij
      '';
    };

    zsessionScript = pkgs.writeShellScriptBin "zsession" ''
      set -euo pipefail
      active_sessions=$(${zellijWrapped}/bin/zellij list-sessions -n 2>/dev/null || true)
      recent_dirs=$(${pkgs.zoxide}/bin/zoxide query -l 2>/dev/null || true)
      selection=$( (
        if [ -n "$active_sessions" ]; then
          echo "$active_sessions" | while read -r s; do [ -n "$s" ] && echo "[session] $s"; done
        fi
        if [ -n "$recent_dirs" ]; then
          echo "$recent_dirs" | head -n 30 | while read -r d; do [ -n "$d" ] && echo "[project] $d"; done
        fi
        echo "[new] Start empty session"
      ) | ${pkgs.fzf}/bin/fzf --prompt="Zellij ➜ " --header="Attach active session or launch project directory")
      [ -z "$selection" ] && exit 0
      tag=$(echo "$selection" | ${pkgs.coreutils}/bin/cut -d " " -f 1)
      val=$(echo "$selection" | ${pkgs.coreutils}/bin/cut -d " " -f 2-)
      if [ -n "''${ZELLIJ:-}" ]; then
        if [ "$tag" = "[session]" ]; then
          exec ${zellijWrapped}/bin/zellij action switch-session "$val"
        elif [ "$tag" = "[project]" ]; then
          name=$(${pkgs.coreutils}/bin/basename "$val" | ${pkgs.coreutils}/bin/tr "." "_")
          exec ${zellijWrapped}/bin/zellij action switch-session "$name" --cwd "$val"
        else
          exec ${zellijWrapped}/bin/zellij action switch-session "scratch-$(${pkgs.coreutils}/bin/date +%H%M%S)"
        fi
      else
        if [ "$tag" = "[session]" ]; then
          exec ${zellijWrapped}/bin/zellij attach "$val"
        elif [ "$tag" = "[project]" ]; then
          name=$(${pkgs.coreutils}/bin/basename "$val" | ${pkgs.coreutils}/bin/tr "." "_")
          exec ${zellijWrapped}/bin/zellij attach -c "$name" options --default-cwd "$val"
        else
          exec ${zellijWrapped}/bin/zellij
        fi
      fi
    '';

    zellijThemeTemplate = pkgs.writeText "zellij-noctalia.kdl.in" ''
      themes {
        noctalia {
          bg "{{colors.terminal_background.default.hex}}"
          fg "{{colors.on_surface.default.hex}}"
          red "{{colors.error.default.hex}}"
          green "{{colors.primary.default.hex}}"
          blue "{{colors.secondary.default.hex}}"
          yellow "{{colors.tertiary.default.hex}}"
          magenta "{{colors.primary.default.hex}}"
          orange "{{colors.tertiary.default.hex}}"
          cyan "{{colors.secondary.default.hex}}"
          black "{{colors.surface_container_highest.default.hex}}"
          white "{{colors.on_surface.default.hex}}"

          ribbon_selected {
            base "{{colors.primary.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.primary.default.hex}}"
            emphasis_1 "{{colors.tertiary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          ribbon_unselected {
            base "{{colors.on_surface_variant.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.on_surface_variant.default.hex}}"
            emphasis_1 "{{colors.tertiary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          text_unselected {
            base "{{colors.on_surface.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.tertiary.default.hex}}"
            emphasis_1 "{{colors.primary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          text_selected {
            base "{{colors.on_surface.default.hex}}"
            background "{{colors.surface_container_high.default.hex}}"
            emphasis_0 "{{colors.tertiary.default.hex}}"
            emphasis_1 "{{colors.primary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          table_title {
            base "{{colors.primary.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.tertiary.default.hex}}"
            emphasis_1 "{{colors.primary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          table_cell_unselected {
            base "{{colors.on_surface.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.tertiary.default.hex}}"
            emphasis_1 "{{colors.primary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          table_cell_selected {
            base "{{colors.on_surface.default.hex}}"
            background "{{colors.surface_container_high.default.hex}}"
            emphasis_0 "{{colors.primary.default.hex}}"
            emphasis_1 "{{colors.tertiary.default.hex}}"
            emphasis_2 "{{colors.secondary.default.hex}}"
            emphasis_3 "{{colors.error.default.hex}}"
          }
          frame_selected {
            base "{{colors.primary.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.primary.default.hex}}"
            emphasis_1 "{{colors.secondary.default.hex}}"
            emphasis_2 "{{colors.tertiary.default.hex}}"
            emphasis_3 "{{colors.primary.default.hex}}"
          }
          frame_highlight {
            base "{{colors.primary.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.primary.default.hex}}"
            emphasis_1 "{{colors.secondary.default.hex}}"
            emphasis_2 "{{colors.tertiary.default.hex}}"
            emphasis_3 "{{colors.primary.default.hex}}"
          }
          frame_unselected {
            base "{{colors.outline_variant.default.hex}}"
            background "{{colors.terminal_background.default.hex}}"
            emphasis_0 "{{colors.outline.default.hex}}"
            emphasis_1 "{{colors.outline_variant.default.hex}}"
            emphasis_2 "{{colors.surface_container_highest.default.hex}}"
            emphasis_3 "{{colors.surface_container.default.hex}}"
          }
        }
      }
    '';

    zellijLayoutTemplate = pkgs.writeText "zellij-default.kdl.in" ''
      layout {
        default_tab_template {
          children
          pane size=1 borderless=true {
            plugin location="file://${zjstatusWasm}" {
              pane_frame_style "full"
              hide_frame_for_single_pane "false"

              format_left   "#[bg={{colors.primary.default.hex}}] #[default] {session}  {tabs}"
              format_center ""
              format_right  "{mode} "
              format_space  ""

              border_enabled "false"
              border_char "─"
              border_format "#[fg={{colors.outline_variant.default.hex}}]{char}"
              border_position "top"

              mode_locked       ""
              mode_normal       "#[fg={{colors.primary.default.hex}}]h/j/k/l #[fg={{colors.on_surface_variant.default.hex}},italic]󰈈 focus #[fg={{colors.primary.default.hex}}]s/v #[fg={{colors.on_surface_variant.default.hex}},italic]󰕮 split #[fg={{colors.primary.default.hex}}]f #[fg={{colors.on_surface_variant.default.hex}},italic]󰊓 full #[fg={{colors.primary.default.hex}}]x #[fg={{colors.on_surface_variant.default.hex}},italic]󰧻 kill #[fg={{colors.primary.default.hex}}]p #[fg={{colors.on_surface_variant.default.hex}},italic]󱥇 pane #[fg={{colors.primary.default.hex}}]t #[fg={{colors.on_surface_variant.default.hex}},italic]󰓩 tab #[fg={{colors.primary.default.hex}}]r #[fg={{colors.on_surface_variant.default.hex}},italic]󰩨 resize #[fg={{colors.primary.default.hex}}]o #[fg={{colors.on_surface_variant.default.hex}},italic]󱂬 session"
              mode_move         "#[fg={{colors.primary.default.hex}}]h/j/k/l #[fg={{colors.on_surface_variant.default.hex}},italic]󰮴 move #[fg={{colors.primary.default.hex}}]n/p #[fg={{colors.on_surface_variant.default.hex}},italic]󱎄 reorder"
              mode_pane         "#[fg={{colors.primary.default.hex}}]h/j/k/l #[fg={{colors.on_surface_variant.default.hex}},italic]󰈈 focus #[fg={{colors.primary.default.hex}}]s/v #[fg={{colors.on_surface_variant.default.hex}},italic]󰕮 split #[fg={{colors.primary.default.hex}}]x #[fg={{colors.on_surface_variant.default.hex}},italic]󰧻 kill #[fg={{colors.primary.default.hex}}]f #[fg={{colors.on_surface_variant.default.hex}},italic]󰊓 full #[fg={{colors.primary.default.hex}}]w #[fg={{colors.on_surface_variant.default.hex}},italic]󰉈 float #[fg={{colors.primary.default.hex}}]c #[fg={{colors.on_surface_variant.default.hex}},italic]󰘙 rename"
              mode_tab          "#[fg={{colors.primary.default.hex}}]h/l #[fg={{colors.on_surface_variant.default.hex}},italic]󰮸 switch #[fg={{colors.primary.default.hex}}]1-9 #[fg={{colors.on_surface_variant.default.hex}},italic] jump #[fg={{colors.primary.default.hex}}]n #[fg={{colors.on_surface_variant.default.hex}},italic]󰝜 new #[fg={{colors.primary.default.hex}}]x #[fg={{colors.on_surface_variant.default.hex}},italic]󰧻 kill #[fg={{colors.primary.default.hex}}]r #[fg={{colors.on_surface_variant.default.hex}},italic]󰂮 rename #[fg={{colors.primary.default.hex}}]s #[fg={{colors.on_surface_variant.default.hex}},italic]󰓦 sync"
              mode_resize       "#[fg={{colors.primary.default.hex}}]h/j/k/l #[fg={{colors.on_surface_variant.default.hex}},italic]󰩨 resize #[fg={{colors.primary.default.hex}}]+/- #[fg={{colors.on_surface_variant.default.hex}},italic]󰩬 scale"
              mode_scroll       "#[fg={{colors.primary.default.hex}}]j/k #[fg={{colors.on_surface_variant.default.hex}},italic]󰮾 scroll #[fg={{colors.primary.default.hex}}]d/u #[fg={{colors.on_surface_variant.default.hex}},italic] half-page #[fg={{colors.primary.default.hex}}]/ #[fg={{colors.on_surface_variant.default.hex}},italic]󰍉 search #[fg={{colors.primary.default.hex}}]e #[fg={{colors.on_surface_variant.default.hex}},italic] edit"
              mode_search       "#[fg={{colors.primary.default.hex}}]n/N #[fg={{colors.on_surface_variant.default.hex}},italic]󰍉 next/prev #[fg={{colors.primary.default.hex}}]c #[fg={{colors.on_surface_variant.default.hex}},italic]󰬲 case #[fg={{colors.primary.default.hex}}]w #[fg={{colors.on_surface_variant.default.hex}},italic]󰑐 wrap #[fg={{colors.primary.default.hex}}]o #[fg={{colors.on_surface_variant.default.hex}},italic]󰬵 word"
              mode_entersearch  "#[fg={{colors.primary.default.hex}}]Enter #[fg={{colors.on_surface_variant.default.hex}},italic]󰍉 search"
              mode_renametab    "#[fg={{colors.primary.default.hex}}]Enter #[fg={{colors.on_surface_variant.default.hex}},italic] submit"
              mode_renamepane   "#[fg={{colors.primary.default.hex}}]Enter #[fg={{colors.on_surface_variant.default.hex}},italic] submit"
              mode_session      "#[fg={{colors.primary.default.hex}}]d #[fg={{colors.on_surface_variant.default.hex}},italic]󰈆 detach #[fg={{colors.primary.default.hex}}]w #[fg={{colors.on_surface_variant.default.hex}},italic]󰀻 manager #[fg={{colors.primary.default.hex}}]p #[fg={{colors.on_surface_variant.default.hex}},italic]󰚝 project #[fg={{colors.primary.default.hex}}]q #[fg={{colors.on_surface_variant.default.hex}},italic]󰧻 kill"
              mode_tmux         ""

              tab_sync_indicator       "󰓦"
              tab_fullscreen_indicator "󰊓"
              tab_floating_indicator   "󰉈"
              tab_separator          " "

              tab_normal              "#[fg={{colors.on_surface.default.hex}}]{name}  "
              tab_normal_fullscreen   "#[fg={{colors.on_surface.default.hex}}]{fullscreen_indicator}{name}  "
              tab_normal_sync         "#[fg={{colors.tertiary.default.hex}},bold,italic]{sync_indicator}#[fg={{colors.on_surface.default.hex}}]{name}  "
              tab_active              "#[fg={{colors.primary.default.hex}},bold,italic]{name}  "
              tab_active_fullscreen   "#[fg={{colors.primary.default.hex}},bold,italic]{fullscreen_indicator}{name}  "
              tab_active_sync         "#[fg={{colors.tertiary.default.hex}},bold,italic]{sync_indicator}#[fg={{colors.primary.default.hex}},bold,italic]{name}  "
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

    zellijFallbackTheme = ''
      themes {
        noctalia {
          bg "#1e1e2e"
          fg "#cdd6f4"
          red "#f38ba8"
          green "#cba6f7"
          blue "#89b4fa"
          yellow "#f9e2af"
          magenta "#cba6f7"
          orange "#fab387"
          cyan "#94e2d5"
          black "#45475a"
          white "#cdd6f4"
        }
      }
    '';
  in {
    home.packages = [zsessionScript];

    programs.zellij = {
      enable = true;
      package = zellijWrapped;
    };

    xdg.configFile = {
      "noctalia/zellij.toml".source =
        (pkgs.formats.toml {}).generate "zellij-template.toml"
        {
          theme.templates.user = {
            zellij = {
              input_path = zellijThemeTemplate;
              output_path = "$XDG_CONFIG_HOME/zellij/themes/noctalia.kdl";
            };
            zellij-layout = {
              input_path = zellijLayoutTemplate;
              output_path = "$XDG_CONFIG_HOME/zellij/layouts/default.kdl";
            };
          };
        };

      "zellij/config.kdl" = {
        text = ''
          default_shell "fish"
          default_mode "locked"
          scroll_buffer_size 10000
          copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
          pane_frames true
          pane_frame_style "full"
          theme "noctalia"

          ui {
            pane_frames {
              rounded_corners true
              hide_session_name true
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
            }

            shared_except "locked" "entersearch" "renametab" "renamepane" {
              bind "Esc" { SwitchToMode "Locked"; }
            }

            shared_except "locked" "entersearch" {
              bind "Enter" { SwitchToMode "Locked"; }
            }

            normal {
              bind "h" "Left" { MoveFocus "Left"; SwitchToMode "Locked"; }
              bind "j" "Down" { MoveFocus "Down"; SwitchToMode "Locked"; }
              bind "k" "Up" { MoveFocus "Up"; SwitchToMode "Locked"; }
              bind "l" "Right" { MoveFocus "Right"; SwitchToMode "Locked"; }

              bind "s" { NewPane "Down"; SwitchToMode "Locked"; }
              bind "v" { NewPane "Right"; SwitchToMode "Locked"; }
              bind "n" { NewPane; SwitchToMode "Locked"; }
              bind "x" { CloseFocus; SwitchToMode "Locked"; }
              bind "f" { ToggleFocusFullscreen; SwitchToMode "Locked"; }
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

              bind "[" { GoToPreviousTab; SwitchToMode "Locked"; }
              bind "]" { GoToNextTab; SwitchToMode "Locked"; }
              bind "Tab" { ToggleTab; SwitchToMode "Locked"; }

              bind "=" "+" { Resize "Increase"; SwitchToMode "Locked"; }
              bind "-" { Resize "Decrease"; SwitchToMode "Locked"; }

              bind "D" { Detach; }
              bind "q" { Quit; }
            }

            pane {
              bind "h" "Left" { MoveFocus "Left"; }
              bind "j" "Down" { MoveFocus "Down"; }
              bind "k" "Up" { MoveFocus "Up"; }
              bind "l" "Right" { MoveFocus "Right"; }

              bind "s" { NewPane "Down"; }
              bind "v" "r" { NewPane "Right"; }
              bind "n" { NewPane; }
              bind "d" { NewPane "stacked"; }
              bind "x" { CloseFocus; }
              bind "f" { ToggleFocusFullscreen; }
              bind "w" { ToggleFloatingPanes; }
              bind "e" { TogglePaneEmbedOrFloating; }
              bind "c" { SwitchToMode "RenamePane"; PaneNameInput 0; }
              bind "i" { TogglePanePinned; }
              bind "Tab" { SwitchFocus; }
              bind "p" { SwitchToMode "Normal"; }
            }

            tab {
              bind "h" "Left" "k" "Up" { GoToPreviousTab; }
              bind "l" "Right" "j" "Down" { GoToNextTab; }
              bind "n" { NewTab; }
              bind "x" { CloseTab; }
              bind "r" { SwitchToMode "RenameTab"; TabNameInput 0; }
              bind "s" { ToggleActiveSyncTab; }
              bind "b" { BreakPane; }
              bind "]" { BreakPaneRight; }
              bind "[" { BreakPaneLeft; }
              bind "1" { GoToTab 1; }
              bind "2" { GoToTab 2; }
              bind "3" { GoToTab 3; }
              bind "4" { GoToTab 4; }
              bind "5" { GoToTab 5; }
              bind "6" { GoToTab 6; }
              bind "7" { GoToTab 7; }
              bind "8" { GoToTab 8; }
              bind "9" { GoToTab 9; }
              bind "0" { GoToTab 10; }
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
              bind "p" {
                Run "${zsessionScript}/bin/zsession" {
                  floating true
                  close_on_exit true
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
    };

    home.activation.seedZellijTheme = lib.hm.dag.entryAfter ["writeBoundary"] ''
      themeFile=${lib.escapeShellArg "${config.xdg.configHome}/zellij/themes/noctalia.kdl"}
      layoutFile=${lib.escapeShellArg "${config.xdg.configHome}/zellij/layouts/default.kdl"}
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$themeFile")" "$(dirname "$layoutFile")"
      if [ ! -f "$themeFile" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
        cat <<'ZTHEME' > "$themeFile"
      ${zellijFallbackTheme}
      ZTHEME
      fi
    '';
  };
}
