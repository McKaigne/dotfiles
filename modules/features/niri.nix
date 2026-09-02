input {
    touchpad {
        tap
        natural-scroll
        scroll-method "two-finger"
    }
}

gestures {
    dnd-edge-view-scroll {
        trigger-width 30
    }
    dnd-edge-workspace-switch {
        trigger-height 50
    }
}

binds {
    // Noctalia Launcher
    "Mod+Space" { action spawn "noctalia" "toggle" "launcher"; }

    // Standard Window Management
    "Mod+Return" { action spawn "ghostty"; }
    "Mod+Q"      { action close-window; }
    "Mod+Tab"    { action toggle-overview; }
}
