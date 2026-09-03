# Nushell Config File

let dark_theme = {
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
    string: white
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
    shape_external_resolved: light_yellow_bold
    shape_filepath: cyan
    shape_flag: blue_bold
    shape_float: purple_bold
    shape_garbage: { fg: white bg: red attr: b}
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
    cursor_shape: {
        emacs: line
        vi_insert: line
        vi_normal: block
    }
    color_config: $dark_theme
    footer_mode: 25
    float_precision: 2
    buffer_editor: "nvim"
    use_ansi_coloring: true
    bracketed_paste: true
    edit_mode: vi
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

# --- Aliases ---
def --env cx [arg] {
    cd $arg
    ls -l
}

alias l = ls --all
alias c = clear
alias ll = ls -l
alias lt = eza --tree --level=2 --long --icons --git
alias v = nvim

# Git aliases
alias gc = git commit -m
alias gca = git commit -a -m
alias gp = git push origin HEAD
alias gpu = git pull origin
alias gst = git status
alias gdiff = git diff
alias gco = git checkout
alias gb = git branch
alias gba = git branch -a
alias gadd = git add
alias ga = git add -p
alias gr = git remote
alias gre = git reset

$env.DIRENV_LOG_FORMAT = ""

# --- Sourcing Tools (Safe checks) ---
if ("~/.zoxide.nu" | path expand | path exists) { source ~/.zoxide.nu }
if ("~/.cache/carapace/init.nu" | path expand | path exists) { source ~/.cache/carapace/init.nu }
if ("~/.cache/starship/init.nu" | path expand | path exists) { use ~/.cache/starship/init.nu }

# Ensure edit_mode is vi
$env.config.edit_mode = "vi"

# Explicit cursor shapes
$env.config.cursor_shape = {
    vi_insert: line
    vi_normal: block
    emacs: line
}
