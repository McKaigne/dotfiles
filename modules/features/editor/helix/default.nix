{ self, inputs, ... }: {
  flake.nixosModules.helix =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      helixLspPath = lib.makeBinPath [
        pkgs.marksman
        pkgs.nixd
        pkgs.nixfmt
        pkgs.bash-language-server
        pkgs.shellcheck
        pkgs.shfmt
        pkgs.taplo
        pkgs.yaml-language-server
        pkgs.lazygit
      ];

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix-wrapped";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${helixLspPath}"
          rm -f $out/bin/helix
          ln -sf hx $out/bin/helix
        '';
      };
    in
    {
      environment.systemPackages = [ wrappedHelix ];

      home-manager.users.${user} = {
        xdg.configFile."helix/languages.toml" = {
          text = ''
            [[language]]
            name = "nix"
            auto-format = true
            formatter = { command = "nixfmt" }
            language-servers = [ "nixd" ]
          '';
          force = true;
        };

        xdg.configFile."helix/config.toml" = {
          text = ''
            theme = "catppuccin_transparent"

            [editor]
            default-yank-register = "+"       # Native Wayland system clipboard sync
            line-number = "relative"          # Relative line numbers for vertical navigation
            mouse = false                     # Pure keyboard-driven modal editing
            cursorline = true                 # Highlight active cursor line
            color-modes = true                # Dynamic color mode badges
            scrolloff = 5                     # Keep 5 lines visible above/below cursor
            auto-save = true                  # Auto-save buffers on focus loss / buffer switch
            auto-format = true                # Format buffers automatically on save
            idle-timeout = 50                 # 50ms delay before triggering diagnostics
            completion-timeout = 5            # 5ms instant completion popup delay
            bufferline = "never"              # Clean minimalist canvas
            gutters = ["diagnostics", "line-numbers", "spacer", "diff"]
            jump-label-alphabet = "jfkdls;aurieowpqnvmcxz" # Home-row prioritized leap labels
            undercurl = true                  # Wavy squiggles for errors/warnings
            rulers = [80, 120]                # Vertical line length guides
            completion-replace = true         # Overwrite text on completion
            popup-border = "all"              # Borders around hover and completion popups
            end-of-line-diagnostics = "hint"  # Show subtle hints at end of line

            [editor.inline-diagnostics]
            cursor-line = "warning"          # Expand full error/warning text inline below cursorline

            [editor.smart-tab]
            supersede-menu = true             # Tab through snippet placeholders without popup interference

            [editor.statusline]
            left = ["mode", "file-name", "file-modification-indicator", "read-only-indicator"]
            center = []
            right = ["diagnostics", "selections", "position", "file-type"]
            separator = " "
            mode.normal = "NOR"
            mode.insert = "INS"
            mode.select = "SEL"

            [editor.cursor-shape]
            normal = "block"
            insert = "bar"
            select = "underline"

            [editor.indent-guides]
            render = false

            [editor.lsp]
            display-inlay-hints = true        # Inline compiler type annotations
            display-messages = true
            display-progress-messages = true

            [keys.normal]
            # Quick Save & Format
            C-s = ":w"                        # Save + auto-format
            "=" = ":format"                   # Format whole buffer on demand without saving

            # Quick Exit (Preserves Ctrl+W window splits)
            "Z" = { "Z" = ":wq", "Q" = ":q!" } # ZZ saves and exits; ZQ discards and quits

            # Navigation & Selections
            ret = "goto_word"                 # Flash/Leap navigation across visible text
            esc = ["collapse_selection", "keep_primary_selection"] # Clean single cursor
            C-a = "select_all"                # Universal Select All
            x = "select_line_below"           # Symmetrical line selection downwards
            X = "select_line_above"           # Symmetrical line selection upwards
            tab = "move_parent_node_end"      # Tree-sitter: jump to end of enclosing block/function
            S-tab = "move_parent_node_start"  # Tree-sitter: jump to start of enclosing block/function

            # Subword Navigation (camelCase & snake_case)
            "A-w" = "move_next_subword_start"
            "A-b" = "move_prev_subword_start"
            "A-e" = "move_next_subword_end"

            [keys.normal.space]
            g = [":write-all", ":insert-output lazygit >/dev/tty", ":redraw", ":reload-all"] # Embedded LazyGit
            c = ":bc"                         # Close active buffer cleanly
            Y = ":yank-filepath"              # Copy relative file path to system clipboard

            [keys.insert]
            C-s = [":w", "normal_mode"]       # Save, auto-format, and drop to Normal mode

            [keys.select]
            ret = "extend_to_word"
            x = "extend_line_below"
            X = "extend_line_above"
            tab = "extend_parent_node_end"
            S-tab = "extend_parent_node_start"
            "A-w" = "extend_next_subword_start"
            "A-b" = "extend_prev_subword_start"
            "A-e" = "extend_next_subword_end"
          '';
          force = true;
        };

        xdg.configFile."helix/themes/catppuccin_transparent.toml" = {
          text = ''
            inherits = "catppuccin_mocha"

            # Transparent Canvas & Cursorlines (Blends with Niri GPU Blur)
            "ui.background" = {}
            "ui.cursorline" = {}
            "ui.cursorline.primary" = {}
            "ui.cursorline.secondary" = {}

            # Minimal Gutters & Relative Line Numbers
            "ui.linenr" = { fg = "surface1" }
            "ui.linenr.selected" = { fg = "lavender", modifiers = ["bold"] }
            "ui.gutter" = {}
            "ui.gutter.selected" = {}

            # Minimal Statusline with Pill Badges
            "ui.statusline" = { fg = "subtext0", bg = "mantle" }
            "ui.statusline.inactive" = { fg = "overlay0", bg = "mantle" }
            "ui.statusline.normal" = { fg = "crust", bg = "mauve", modifiers = ["bold"] }
            "ui.statusline.insert" = { fg = "crust", bg = "green", modifiers = ["bold"] }
            "ui.statusline.select" = { fg = "crust", bg = "peach", modifiers = ["bold"] }
            "ui.statusline.separator" = { fg = "surface0" }

            # Overlays & Popups (Solid Surfaces for Code Readability)
            "ui.popup" = { fg = "text", bg = "surface0" }
            "ui.popup.info" = { fg = "blue", modifiers = ["bold"] }
            "ui.help" = { fg = "subtext1", bg = "surface0" }

            "ui.menu" = { fg = "text", bg = "surface0" }
            "ui.menu.selected" = { fg = "crust", bg = "mauve", modifiers = ["bold"] }
            "ui.menu.scroll" = { fg = "surface2", bg = "surface0" }

            "ui.window" = { fg = "surface0" }
          '';
          force = true;
        };
      };
    };
}
