
# Nushell Config File (Dynamic Palette Integration)

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
        vi_insert: line
        vi_normal: block
        emacs: line
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
    buffer_editor: "nvim"
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

# --- Core Abbreviations & Aliases ---
def --env cx [arg] { cd $arg; ls -l }

alias c = clear
alias l = ls --all
alias ll = ls -l
alias lt = eza --tree --level=2 --long --icons --git
alias cat = bat --paging=never
alias v = nvim

# App shortcuts
alias e = emacsclient -c -a 'emacs'
alias y = yazi
alias f = fetch

# Nix & Rebuild Abbreviations
alias nr = sudo nixos-rebuild switch --flake /etc/nixos#castor
alias nfu = nix flake update --flake /etc/nixos
alias ncd = cd /etc/nixos

# Git Abbreviations
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

# Zoxide Abbreviations
alias z = __zoxide_z
alias zi = __zoxide_zi
alias za = zoxide add

$env.DIRENV_LOG_FORMAT = ""

# --- Sourcing Tools ---
if ("~/.zoxide.nu" | path expand | path exists) { source ~/.zoxide.nu }
if ("~/.cache/carapace/init.nu" | path expand | path exists) { source ~/.cache/carapace/init.nu }
if ("~/.cache/starship/init.nu" | path expand | path exists) { use ~/.cache/starship/init.nu }
