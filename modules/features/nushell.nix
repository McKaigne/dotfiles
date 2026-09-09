{ self, ... }: {
  flake.nixosModules.nushell = { pkgs, ... }: {
    programs.nushell.enable = true;

    environment.shells = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];

    users.defaultUserShell = self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell;

    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myNushell
    ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      shellTools = with pkgs; [
        starship
        zoxide
        carapace
        eza
        fzf
        neovim
        direnv
        nix-direnv
        atuin
        self.packages.${pkgs.stdenv.hostPlatform.system}.helix
        self.packages.${pkgs.stdenv.hostPlatform.system}.tmux
      ];

      starshipConfig = pkgs.writeText "starship.toml" ''
        add_newline = false
        format = """$directory$character"""
        palette = "noctalia"
        right_format = """$nix_shell$git_branch$git_status$c$python$rust$zig$nodejs$cmd_duration"""
        command_timeout = 1000

        [character]
        vicmd_symbol = "[N] >>>"
        success_symbol = '[➜](bold green)'
        error_symbol = '[➜](bold red)'

        [directory]
        read_only = " 󰌾"
        truncation_length = 3
        truncation_symbol = "…/"
        style = "bold cyan"

        [directory.substitutions]
        '~/tests/starship-custom' = 'work-project'
        '~/Projects' = '󰲋 Projects'

        [nix_shell]
        symbol = " "
        format = 'via [$symbol($name)]($style) '
        style = "bold cyan"
        impure_msg = ""
        pure_msg = ""

        [git_branch]
        symbol = " "
        format = '[$symbol$branch(:$remote_branch)]($style) '
        style = "bold magenta"

        [git_status]
        format = '([$all_status$ahead_behind]($style) )'
        style = "bold red"

        [c]
        symbol = " "
        format = '[$symbol($version(-$name))]($style) '
        style = "bold blue"

        [python]
        symbol = " "
        format = '[''${symbol}''${pyenv_prefix}(''${version})(\(''${virtualenv}\))](''${style}) '
        style = "bold yellow"

        [rust]
        symbol = " "
        format = '[$symbol($version)]($style) '
        style = "bold red"

        [zig]
        symbol = " "
        format = '[$symbol($version)]($style) '
        style = "bold yellow"

        [nodejs]
        symbol = " "
        format = '[$symbol($version)]($style) '
        style = "bold green"

        [cmd_duration]
        min_time = 2_000
        format = 'took [$duration]($style) '
        style = "bold yellow"

        [docker_context]
        disabled = true

        [palettes.noctalia]
        blue      = "#7fbbb3"
        red       = "#e67e80"
        green     = "#a7c080"
        yellow    = "#dbbc7f"
        cyan      = "#83c092"
        magenta   = "#d699b6"
        white     = "#f2efdf"
        black     = "#7a8478"
        rosewater = "#dfa000"
        flamingo  = "#f85552"
        pink      = "#df69ba"
        mauve     = "#d699b6"
        maroon    = "#f85552"
        peach     = "#dfa000"
        teal      = "#83c092"
        sky       = "#35a77c"
        sapphire  = "#3a94c5"
        lavender  = "#df69ba"
        text      = "#d3c6aa"
        subtext1  = "#f2efdf"
        subtext0  = "#a6b0a0"
        overlay2  = "#a6b0a0"
        overlay1  = "#a6b0a0"
        overlay0  = "#7a8478"
        surface2  = "#7a8478"
        surface1  = "#7a8478"
        surface0  = "#1e2326"
        base      = "#1e2326"
        mantle    = "#1e2326"
        crust     = "#1e2326"
      '';

      envNu = pkgs.writeText "env.nu" ''
        $env.STARSHIP_CONFIG = "${starshipConfig}"
        $env.EDITOR = "emacsclient -t -a 'emacs'"
        $env.VISUAL = "emacsclient -c -a 'emacs'"

        $env.ENV_CONVERSIONS = {
            "PATH": {
                from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
                to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
            }
        }

        $env.NU_LIB_DIRS = [
            ($nu.default-config-dir | path join 'scripts')
            ($nu.data-dir | path join 'completions')
        ]

        $env.NU_PLUGIN_DIRS = [
            ($nu.default-config-dir | path join 'plugins')
        ]

        use std "path add"
        path add "/run/current-system/sw/bin"
        path add "/run/wrappers/bin"
        path add ($env.HOME | path join ".nix-profile/bin")
        path add ($env.HOME | path join ".local/bin")
        path add ($env.HOME | path join ".config/emacs/bin")

        let cache_dir = ($env.HOME | path join ".cache")
        mkdir ($cache_dir | path join "starship")
        mkdir ($cache_dir | path join "carapace")

        if (which starship | is-not-empty) {
            starship init nu | save -f ($cache_dir | path join "starship/init.nu")
        }
        if (which zoxide | is-not-empty) {
            zoxide init nushell | save -f ($env.HOME | path join ".zoxide.nu")
        }
        if (which carapace | is-not-empty) {
            $env.CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
            carapace _carapace nushell | save --force ($cache_dir | path join "carapace/init.nu")
        }
      '';

      configNu = pkgs.writeText "config.nu" ''
        let dynamic_theme = {
            separator: white
            leading_trailing_space_bg: { attr: n }
            header: green_bold
            empty: blue
            bool: light_cyan
            int: white
            filesize: cyan
            duration: white
            date: purple
            range: white
            float: white
            string: green
            nothing: white
            binary: white
            cell-path: white
            row_index: green_bold
            record: white
            list: white
            block: white
            hints: dark_gray
            search_result: { bg: red fg: white }
            shape_and: purple_bold
            shape_binary: purple_bold
            shape_block: blue_bold
            shape_bool: light_cyan
            shape_closure: green_bold
            shape_custom: green
            shape_datetime: cyan_bold
            shape_directory: cyan
            shape_external: cyan
            shape_externalarg: green_bold
            shape_external_resolved: yellow_bold
            shape_filepath: cyan
            shape_flag: blue_bold
            shape_float: purple_bold
            shape_garbage: { fg: white bg: red attr: b }
            shape_glob_interpolation: cyan_bold
            shape_globpattern: cyan_bold
            shape_int: purple_bold
            shape_internalcall: cyan_bold
            shape_keyword: cyan_bold
            shape_list: cyan_bold
            shape_literal: blue
            shape_match_pattern: green
            shape_matching_brackets: { attr: u }
            shape_nothing: light_cyan
            shape_operator: yellow
            shape_or: purple_bold
            shape_pipe: purple_bold
            shape_range: yellow_bold
            shape_record: cyan_bold
            shape_redirection: purple_bold
            shape_signature: green_bold
            shape_string: green
            shape_string_interpolation: cyan_bold
            shape_table: blue_bold
            shape_variable: purple
            shape_vardecl: purple
            shape_raw_string: light_purple
        }

        $env.config = {
            show_banner: false
            edit_mode: vi
            cursor_shape: {
                vi_insert: block
                vi_normal: block
                emacs: block
            }
            color_config: $dynamic_theme
            ls: { use_ls_colors: true }
            rm: { always_trash: false }
            table: {
                mode: rounded
                index_mode: always
                show_empty: true
                padding: { left: 1, right: 1 }
                trim: {
                    methodology: wrapping
                    wrapping_try_keep_words: true
                    truncating_suffix: "..."
                }
                header_on_separator: false
            }
            error_style: "fancy"
            history: {
                max_size: 100_000
                sync_on_enter: true
                file_format: "plaintext"
                isolation: false
            }
            completions: {
                case_sensitive: false
                quick: true
                partial: true
                algorithm: "prefix"
                external: {
                    enable: true
                    max_results: 100
                    completer: null
                }
                use_ls_colors: true
            }
            footer_mode: 25
            float_precision: 2
            buffer_editor: "emacsclient"
            use_ansi_coloring: true
            bracketed_paste: true
            shell_integration: {
                osc2: true
                osc7: true
                osc8: true
                osc9_9: false
                osc133: true
                osc633: true
                reset_application_mode: true
            }
            render_right_prompt_on_last_line: false
            use_kitty_protocol: false
            highlight_resolved_externals: false
            recursion_limit: 50

            hooks: {
                pre_prompt: [{||
                    if (which direnv | is-empty) { return }
                    try {
                        direnv export json | from json | default {} | load-env
                        if 'PATH' in $env {
                            $env.PATH = ($env.PATH | split row (char esep))
                        }
                    } catch {}
                }]
                pre_execution: [{ null }]
                env_change: { PWD: [] }
                display_output: "if (term size).columns >= 100 { table -e } else { table }"
                command_not_found: { null }
            }
        }

        def --env cx [arg] { cd $arg; ls -l }

        alias c = clear
        alias l = ls --all
        alias ll = ls -l
        alias lt = eza --tree --level=2 --long --icons --git
        alias cat = bat --paging=never
        alias v = emacsclient -c -a 'emacs'

        alias e = emacsclient -c -a 'emacs'
        alias et = emacsclient -t -a 'emacs'
        alias fm = thunar
        alias y = yazi
        alias f = fetch

        alias h = hx
        alias h. = hx .

        alias t = tmux
        alias ta = tmux attach
        alias tls = tmux list-sessions
        alias tn = tmux new -s
        alias tk = tmux kill-session -t
        alias tka = tmux kill-server

        alias nr = sudo nixos-rebuild switch --flake /etc/nixos#castor
        alias nfu = nix flake update --flake /etc/nixos
        alias ncd = cd /etc/nixos

        alias g = git
        alias ga = git add -A
        alias gc = git commit -m
        alias gca = git commit -a -m
        alias gp = git push
        alias gpu = git pull
        alias gst = git status
        alias gd = git diff
        alias gco = git checkout
        alias gb = git branch
        alias glog = git log --oneline --graph --decorate

        alias z = __zoxide_z
        alias zi = __zoxide_zi
        alias za = zoxide add

        $env.DIRENV_LOG_FORMAT = ""

        if ("~/.zoxide.nu" | path expand | path exists) { source ~/.zoxide.nu }
        if ("~/.cache/carapace/init.nu" | path expand | path exists) { source ~/.cache/carapace/init.nu }
        if ("~/.cache/starship/init.nu" | path expand | path exists) { use ~/.cache/starship/init.nu }
      '';

      myNushell = pkgs.symlinkJoin {
        name = "my-nushell";
        paths = [ pkgs.nushell ];
        buildInputs = [ pkgs.makeWrapper ];
        passthru = {
          shellPath = "/bin/nu";
        };
        postBuild = ''
          wrapProgram $out/bin/nu \
            --prefix PATH : ${lib.makeBinPath shellTools} \
            --set STARSHIP_CONFIG "${starshipConfig}" \
            --add-flags "--config" --add-flags "${configNu}" \
            --add-flags "--env-config" --add-flags "${envNu}"
        '';
      };
    in
    {
      packages.myNushell = myNushell;

      apps.nushell = {
        type = "app";
        program = "${myNushell}/bin/nu";
        meta.description = "Hermetically wrapped Nushell with in-store configurations";
      };
    };
}