function fish_greeting
    if test -t 1
        # microfetch uses ANSI palette slots; foot's Noctalia theme maps them.
        env -u NO_COLOR microfetch
    end
end

if status is-interactive
    set -gx GPG_TTY (tty)

    # foot reflows the screen itself on a resize, and fish doesn't know it,
    # so both redrew the two-line prompt and every resize left a copy behind.
    if string match -q 'foot*' -- $TERM
        set -g fish_handle_reflow 0
    end

    if test -d "$HOME/.bun"
        set -gx BUN_INSTALL "$HOME/.bun"
        fish_add_path $BUN_INSTALL/bin
    end

    if test -d "$HOME/.opencode/bin"
        fish_add_path "$HOME/.opencode/bin"
    end
end
