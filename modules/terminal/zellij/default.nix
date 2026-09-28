{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zellij
    ];
  };
in
{
  flake.nixosModules.zellij = nixosModule;

  perSystem = { pkgs, ... }:
    let
      zjstatusWasm = pkgs.fetchurl {
        url = "https://github.com/dj95/zjstatus/releases/download/v0.22.0/zjstatus.wasm";
        sha256 = "4de426d20b1cbf861272e927aeeb5b49d92c17f0e2bb9d173f85bf7f0154dd53";
      };

      zellijLayout = pkgs.writeText "default.kdl" ''
        layout {
          pane
          pane size=1 borderless=true {
            plugin location="file:${zjstatusWasm}" {
              // Left: Mode Glyph + Session + Stationary Tabs
              format_left   "{mode} #[fg=$fg,bold]□ {session}#[fg=$black]    {tabs}"
              format_center ""
              // Right: Ephemeral Jetpack Mode Hints
              format_right  "{mode_hints}"
              format_space  ""

              // Tabs: ▶ marks active tab; inactive tabs are muted with middle-dot separators
              tab_normal   "#[fg=$black] {index} {name} #[fg=$black]·"
              tab_active   "#[fg=$fg,bold]▶ {index} {name} #[fg=$black]·"
              tab_sync     "#[fg=$yellow]󰊓 "

              // --- MODE GLYPHS (Anchored Left, identical 2-character width) ---
              mode_locked  "#[fg=$black,bold]⬡ "
              mode_normal  "#[fg=$magenta,bold]⬢ "
              mode_pane    "#[fg=$cyan,bold]⬟ "
              mode_tab     "#[fg=$yellow,bold]■ "
              mode_resize  "#[fg=$blue,bold]▲ "
              mode_scroll  "#[fg=$green,bold]● "
              mode_session "#[fg=$magenta,bold]⬢ "

              // --- EPHEMERAL HINTS (Pinned to Far Right margin) ---
              mode_hints_locked  ""
              mode_hints_normal  "#[fg=$fg]⎪#[fg=$cyan]p#[fg=$black]│#[fg=$fg]pane #[fg=$yellow]t#[fg=$black]│#[fg=$fg]tab #[fg=$blue]r#[fg=$black]│#[fg=$fg]size #[fg=$green]s#[fg=$black]│#[fg=$fg]scroll #[fg=$red]q#[fg=$black]│#[fg=$fg]quit⎥ "
              mode_hints_pane    "#[fg=$fg]⎪#[fg=$cyan]r#[fg=$black]│#[fg=$fg]right #[fg=$cyan]d#[fg=$black]│#[fg=$fg]down #[fg=$cyan]n#[fg=$black]│#[fg=$fg]new #[fg=$cyan]x#[fg=$black]│#[fg=$fg]close #[fg=$cyan]f#[fg=$black]│#[fg=$fg]zoom #[fg=$cyan]h/j/k/l#[fg=$black]│#[fg=$fg]move⎥ "
              mode_hints_tab     "#[fg=$fg]⎪#[fg=$yellow]n#[fg=$black]│#[fg=$fg]new #[fg=$yellow]x#[fg=$black]│#[fg=$fg]close #[fg=$yellow]r#[fg=$black]│#[fg=$fg]rename #[fg=$yellow]h/l#[fg=$black]│#[fg=$fg]nav #[fg=$yellow]1-9#[fg=$black]│#[fg=$fg]jump⎥ "
              mode_hints_resize  "#[fg=$fg]⎪#[fg=$blue]+/-#[fg=$black]│#[fg=$fg]size #[fg=$blue]h/j/k/l#[fg=$black]│#[fg=$fg]direction⎥ "
              mode_hints_scroll  "#[fg=$fg]⎪#[fg=$green]s#[fg=$black]│#[fg=$fg]search #[fg=$green]e#[fg=$black]│#[fg=$fg]helix #[fg=$green]j/k#[fg=$black]│#[fg=$fg]scroll #[fg=$green]d/u#[fg=$black]│#[fg=$fg]page⎥ "
            }
          }
        }
      '';

      zellijConfig = pkgs.writeText "config.kdl" ''
        pane_frames false
        default_layout "default"
        default_mode "locked"
        theme "noctalia"

        // Clear all conflicting defaults to guarantee Helix / Nushell compatibility
        keybinds clear-defaults=true {
          // Locked Mode: Only the Kanata (n m) -> Ctrl+b trigger unlocks Zellij
          locked {
            bind "Ctrl b" { SwitchToMode "Normal"; }
          }

          // Normal Mode: Single-letter gateway into submodes
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

          // Pane Mode: Clean single-key operations with zero modifiers held
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

          // Tab Mode: Single-key tab navigation and creation
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

          // Resize Mode: Fluid single-key taps (+, -, h/j/k/l)
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

          // Scrollback Mode: Vim navigation + direct dump to Helix
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

      zellijConfigDir = pkgs.runCommand "zellij-config-dir" {} ''
        mkdir -p $out/zellij/layouts
        cp ${zellijConfig} $out/zellij/config.kdl
        cp ${zellijLayout} $out/zellij/layouts/default.kdl
      '';

      wrappedZellij = pkgs.symlinkJoin {
        name = "zellij";
        paths = [ pkgs.zellij ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zellij \
            --set ZELLIJ_CONFIG_DIR "${zellijConfigDir}/zellij"
        '';
      };
    in
    {
      packages.zellij = wrappedZellij;

      apps.zellij = {
        type = "app";
        program = "${wrappedZellij}/bin/zellij";
        meta.description = "Pure modal Zellij workspace triggered by Kanata (n m) chord";
      };
    };
}
