{ self, ... }:
let
  nixosModule = { config, pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.zed-editor
    ];

    # Auto-whitelist ~/Projects so direnv never requires manual 'direnv allow'
    environment.etc."xdg/direnv/direnv.toml".text = ''
      [whitelist]
      prefix = [ "/home/${config.mainUser}/Projects" ]
    '';
  };
in
{
  flake.nixosModules.zed = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      fixedCursor = self'.packages.bibata-cursors-fixed;
      iconPath = "${fixedCursor}/share/icons:/run/current-system/sw/share/icons";

      # Core editor utilities; language toolchains are provided per-project via devenv
      zedRuntimeDeps = with pkgs; [
        direnv
        git
        wl-clipboard
        nixd
        nixfmt
        lua-language-server
        stylua
        taplo
        marksman
      ];

      zedSettings = pkgs.writeText "settings.json" (builtins.toJSON {
        helix_mode = true;
        theme = "Noctalia Dark";
        load_direnv = "shell_hook";
        buffer_font_family = "Maple Mono NF";
        buffer_font_size = 14;
        ui_font_family = "Maple Mono NF";
        ui_font_size = 14;
        cursor_shape = "bar";
        relative_line_numbers = true;
        auto_update = false;

        telemetry = {
          diagnostics = false;
          metrics = false;
        };

        vim = {
          use_system_clipboard = "always";
          cursor_shape = {
            normal = "block";
            insert = "bar";
            visual = "block";
            replace = "underline";
          };
        };

        language_servers = [
          "!package-version-server"
          "..."
        ];

        languages = {
          "Nix" = {
            format_on_save = "on";
            formatter = {
              external = {
                command = "nixfmt";
              };
            };
            language_servers = [ "nixd" "..." ];
          };
          "Lua" = {
            format_on_save = "on";
            formatter = {
              external = {
                command = "stylua";
                arguments = [ "--stdin-filepath" "{buffer_path}" "-" ];
              };
            };
            language_servers = [ "lua-language-server" "..." ];
          };
          "TOML" = {
            format_on_save = "on";
            language_servers = [ "taplo" "..." ];
          };
          "Markdown" = {
            format_on_save = "on";
            language_servers = [ "marksman" "..." ];
          };
          "JSON" = {
            language_servers = [ "!package-version-server" "..." ];
          };
          "JSONC" = {
            language_servers = [ "!package-version-server" "..." ];
          };
        };

        lsp = {
          nixd = {
            binary = { path_lookup = true; };
          };
          lua-language-server = {
            binary = { path_lookup = true; };
          };
          taplo = {
            binary = { path_lookup = true; };
          };
          marksman = {
            binary = { path_lookup = true; };
          };
        };
      });

      zedTasks = pkgs.writeText "tasks.json" (builtins.toJSON [
        {
          label = "Project: New C++ (From Template)";
          command = "read -p 'Enter new C++ project name: ' name; if [ -n \"$name\" ]; then if [ -d \"$HOME/Projects/$name\" ]; then echo \"Directory already exists!\"; else cp -r \"$HOME/Projects/templates/cpp\" \"$HOME/Projects/$name\" && zed \"$HOME/Projects/$name\"; fi; fi";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
        {
          label = "Quickrun: Current File";
          command = "if [ \"$ZED_FILE_EXTENSION\" = \"py\" ]; then python3 -u \"$ZED_FILE\"; elif [ \"$ZED_FILE_EXTENSION\" = \"sh\" ]; then bash \"$ZED_FILE\"; fi";
          use_new_terminal = false;
          allow_concurrent_runs = false;
        }
        {
          label = "Quickrun: Run Selected Text";
          command = "bash -c \"$ZED_SELECTED_TEXT\"";
          use_new_terminal = false;
        }
      ]);

      zedKeymap = pkgs.writeText "keymap.json" (builtins.toJSON [
        {
          context = "Editor && (vim_mode == normal || vim_mode == visual) && !VimWaiting && !menu";
          bindings = {
            # --- Root Doom Leaders ---
            "space space" = "file_finder::Toggle";
            "space ." = "file_finder::Toggle";
            "space ," = "tab_switcher::Toggle";
            "space <" = "tab_switcher::Toggle";
            "space :" = "command_palette::Toggle";
            "space ;" = "buffer_search::Deploy";
            "space '" = [ "pane::DeploySearch" { "replace_enabled" = true; } ];
            "space `" = "terminal_panel::ToggleFocus";
            "space /" = "workspace::NewSearch";
            "space *" = "editor::SelectAllMatches";
            "space x" = "pane::CloseActiveItem";
            "space X" = "pane::CloseOtherItems";
            "] b" = "pane::ActivateNextItem";
            "[ b" = "pane::ActivatePreviousItem";

            # --- Buffers (SPC b) ---
            "space b b" = "tab_switcher::Toggle";
            "space b d" = "pane::CloseActiveItem";
            "space b k" = "pane::CloseActiveItem";
            "space b o" = "pane::CloseOtherItems";
            "space b s" = "workspace::Save";
            "space b S" = "workspace::SaveAll";
            "space b n" = "pane::ActivateNextItem";
            "space b p" = "pane::ActivatePreviousItem";
            "space b r" = "workspace::Reload";
            "space b N" = "workspace::NewFile";
            "space b y" = "editor::CopyPath";
            "space b shift-y" = "editor::CopyRelativePath";

            # --- Files (SPC f) ---
            "space f f" = "file_finder::Toggle";
            "space f s" = "workspace::Save";
            "space f shift-s" = "workspace::SaveAs";
            "space f r" = "file_finder::Toggle";
            "space f y" = "editor::CopyPath";
            "space f shift-y" = "editor::CopyRelativePath";
            "space f d" = "editor::RevealInFileManager";

            # --- Code, Refactor & Tasks (SPC c) ---
            "space c d" = "editor::GoToDefinition";
            "space c shift-d" = "editor::GoToDefinitionSplit";
            "space c i" = "editor::GoToImplementation";
            "space c t" = "editor::GoToTypeDefinition";
            "space c a" = "editor::ToggleCodeActions";
            "space c r" = "editor::Rename";
            "space c f" = "editor::Format";
            "space c l" = "editor::ToggleComments";
            "space c c" = "task::Spawn";
            "space c shift-c" = "task::Rerun";
            "space c k" = "repl::Shutdown";
            "space c x" = "diagnostics::Deploy";
            "space c e" = "repl::Run";

            # --- DAP Debugger (SPC d) ---
            "space d d" = "debugger::Start";
            "space d b" = "editor::ToggleBreakpoint";
            "space d c" = "debugger::Continue";
            "space d s" = "debugger::StepInto";
            "space d i" = "debugger::StepInto";
            "space d n" = "debugger::StepOver";
            "space d o" = "debugger::StepOver";
            "space d shift-o" = "debugger::StepOut";
            "space d p" = "debugger::Pause";
            "space d r" = "debugger::Restart";
            "space d q" = "debugger::Stop";
            "space d e" = "debugger::EvaluateSelectedText";

            # --- Git & Magit (SPC g) ---
            "space g g" = "git_panel::ToggleFocus";
            "space g b" = "editor::ToggleGitBlame";
            "space g ]" = "editor::GoToHunk";
            "space g [" = "editor::GoToPreviousHunk";
            "space g r" = "editor::RevertHunk";
            "space g d" = "editor::ToggleDiff";
            "space g f" = "file_finder::Toggle";

            # --- Open & Docks Menu (SPC o) ---
            "space o t" = "terminal_panel::ToggleFocus";
            "space o shift-t" = "workspace::NewTerminal";
            "space o p" = "project_panel::ToggleFocus";
            "space o g" = "git_panel::ToggleFocus";
            "space o o" = "outline_panel::ToggleFocus";
            "space o a" = "agent::ToggleFocus";
            "space o d" = "diagnostics::Deploy";
            "space o r" = "repl::Run";
            "space o shift-p" = "pane::RevealInProjectPanel";
            "space o f" = "editor::RevealInFileManager";
            "space o s" = "zed::OpenSettings";
            "space o k" = "zed::OpenKeymap";

            # --- Projects (SPC p) ---
            "space p p" = "projects::OpenRecent";
            "space p n" = [ "task::Spawn" { "task_name" = "Project: New C++ (From Template)"; } ];
            "space p f" = "file_finder::Toggle";
            "space p /" = "workspace::NewSearch";
            "space p s" = "workspace::NewSearch";
            "space p c" = "task::Spawn";
            "space p shift-c" = "task::Rerun";
            "space p k" = "pane::CloseOtherItems";
            "space p d" = "pane::RevealInProjectPanel";
            "space p t" = "terminal_panel::ToggleFocus";

            # --- Search (SPC s) ---
            "space s p" = "workspace::NewSearch";
            "space s s" = "buffer_search::Deploy";
            "space s b" = "buffer_search::Deploy";
            "space s i" = "outline::Toggle";
            "space s shift-i" = "project_symbols::Toggle";
            "space s r" = [ "pane::DeploySearch" { "replace_enabled" = true; } ];

            # --- Toggles (SPC t) ---
            "space t z" = "pane::ToggleZoom";
            "space t w" = "editor::ToggleSoftWrap";
            "space t i" = "editor::ToggleInlayHints";
            "space t b" = "editor::ToggleGitBlame";
            "space t t" = "terminal_panel::ToggleFocus";
            "space t p" = "project_panel::ToggleFocus";
            "space t g" = "git_panel::ToggleFocus";
            "space t o" = "outline_panel::ToggleFocus";
            "space t a" = "agent::ToggleFocus";
            "space t d" = "diagnostics::Deploy";

            # --- Window Splits & Controls (SPC w) ---
            "space w v" = "pane::SplitRight";
            "space w s" = "pane::SplitDown";
            "space w h" = [ "workspace::ActivatePaneInDirection" "Left" ];
            "space w l" = [ "workspace::ActivatePaneInDirection" "Right" ];
            "space w k" = [ "workspace::ActivatePaneInDirection" "Up" ];
            "space w j" = [ "workspace::ActivatePaneInDirection" "Down" ];
            "space w shift-h" = [ "workspace::SwapPaneInDirection" "Left" ];
            "space w shift-l" = [ "workspace::SwapPaneInDirection" "Right" ];
            "space w shift-k" = [ "workspace::SwapPaneInDirection" "Up" ];
            "space w shift-j" = [ "workspace::SwapPaneInDirection" "Down" ];
            "space w c" = "pane::CloseActiveItem";
            "space w d" = "pane::CloseActiveItem";
            "space w o" = "pane::CloseOtherItems";
            "space w m" = "pane::ToggleZoom";
            "space w =" = "pane::Rebalance";
            "space w shift-left"  = [ "pane::MoveItemToDirection" "Left" ];
            "space w shift-right" = [ "pane::MoveItemToDirection" "Right" ];
            "space w shift-up"    = [ "pane::MoveItemToDirection" "Up" ];
            "space w shift-down"  = [ "pane::MoveItemToDirection" "Down" ];

            # --- Help & Documentation (SPC h) ---
            "space h t" = "theme_selector::Toggle";
            "space h k" = "zed::OpenKeymap";
            "space h v" = "zed::OpenSettings";
            "space h f" = "command_palette::Toggle";
            "space h r r" = "workspace::Reload";

            # --- Quit & Session (SPC q) ---
            "space q q" = "zed::Quit";
            "space q w" = "workspace::CloseWindow";
            "space q r" = "workspace::Reload";
            "space q s" = "workspace::SaveAll";

            # --- Major Mode & REPL (SPC m) ---
            "space m r" = "repl::Run";
            "space m e" = "repl::Run";
            "space m shift-r" = "repl::RunInPlace";
            "space m s" = "repl::Sessions";
            "space m k" = "repl::Shutdown";
          };
        }
        {
          # Universal Tab Navigation inside the Terminal Panel
          context = "Terminal";
          bindings = {
            "ctrl-pageup" = "pane::ActivatePreviousItem";
            "ctrl-pagedown" = "pane::ActivateNextItem";
          };
        }
        {
          # Fallback when no buffer is open
          context = "EmptyPane || SharedScreen";
          bindings = {
            "space space" = "file_finder::Toggle";
            "space ." = "file_finder::Toggle";
            "space f" = "file_finder::Toggle";
            "space p p" = "projects::OpenRecent";
            "space p n" = [ "task::Spawn" { "task_name" = "Project: New C++ (From Template)"; } ];
            "space o t" = "terminal_panel::ToggleFocus";
            "space o p" = "project_panel::ToggleFocus";
            "space o s" = "zed::OpenSettings";
            "space c c" = "task::Spawn";
            "space d d" = "debugger::Start";
          };
        }
        {
          context = "ProjectPanel && not_editing";
          bindings = {
            "h" = "project_panel::CollapseSelectedEntry";
            "j" = "menu::SelectNext";
            "k" = "menu::SelectPrev";
            "l" = "project_panel::ExpandSelectedEntry";
            "o" = "project_panel::Open";
            "enter" = "project_panel::Open";
            "a" = "project_panel::NewFile";
            "shift-a" = "project_panel::NewDirectory";
            "r" = "project_panel::Rename";
            "d" = "project_panel::Delete";
            "x" = "project_panel::Cut";
            "y" = "project_panel::Copy";
            "p" = "project_panel::Paste";
            "q" = "project_panel::ToggleFocus";
            "escape" = "project_panel::ToggleFocus";
            "space o p" = "project_panel::ToggleFocus";
            "space space" = "file_finder::Toggle";
            "space p p" = "projects::OpenRecent";
          };
        }
      ]);

      wrappedZed = pkgs.symlinkJoin {
        name = "zed-editor";
        paths = [ pkgs.zed-editor ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/zeditor \
            --prefix PATH : ${lib.makeBinPath zedRuntimeDeps} \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}" \
            --run '
              ZED_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/zed"
              mkdir -p "$ZED_DIR"
              cp -f "${zedSettings}" "$ZED_DIR/settings.json"
              chmod u+w "$ZED_DIR/settings.json"
              cp -f "${zedKeymap}" "$ZED_DIR/keymap.json"
              chmod u+w "$ZED_DIR/keymap.json"
              cp -f "${zedTasks}" "$ZED_DIR/tasks.json"
              chmod u+w "$ZED_DIR/tasks.json"
            '

          [ -e $out/bin/zed ] || ln -sf $out/bin/zeditor $out/bin/zed
          [ -e $out/bin/zed-editor ] || ln -sf $out/bin/zeditor $out/bin/zed-editor
        '';
      };
    in
    {
      packages.zed-editor = wrappedZed;
      packages.zed = wrappedZed;

      apps.zed-editor = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with Helix mode and Doom Emacs keymaps";
      };
      apps.zed = {
        type = "app";
        program = "${wrappedZed}/bin/zed";
        meta.description = "Hermetically wrapped Zed editor with Helix mode and Doom Emacs keymaps";
      };
    };
}