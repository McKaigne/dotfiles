config.load_autoconfig(False)

# 1. Hardware GPU Acceleration & Engine Settings
c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-zero-copy',
    'enable-accelerated-video-decode',
    'enable-features=VaapiVideoDecodeLinuxGL,VaapiVideoEncoder,CanvasOopRasterization',
    'disable-features=TrustedTypes',
    'disable-blink-features=TrustedTypes',
]

# 2. Functional Settings
c.auto_save.session = True
c.session.lazy_restore = True
c.colors.webpage.darkmode.enabled = True
c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
c.colors.webpage.darkmode.policy.images = 'never'
c.colors.webpage.preferred_color_scheme = 'dark'
c.content.blocking.enabled = True
c.content.blocking.method = 'both'

# 3. Community Aesthetic Enhancements (Typography & Chrome)
c.fonts.default_family = "Lilex Nerd Font"
c.fonts.default_size = "10pt"
c.fonts.tabs.selected = "bold 10pt default_family"
c.fonts.tabs.unselected = "10pt default_family"
c.fonts.hints = "bold 10pt default_family"
c.fonts.statusbar = "10pt default_family"
c.fonts.keyhint = "10pt default_family"
c.fonts.messages.info = "10pt default_family"

c.tabs.padding = {"top": 4, "bottom": 4, "left": 8, "right": 8}
c.statusbar.padding = {"top": 4, "bottom": 4, "left": 8, "right": 8}
c.hints.padding = {"top": 2, "bottom": 2, "left": 4, "right": 4}
c.hints.radius = 4

c.tabs.show = "multiple"
c.tabs.title.format = "{index}: {current_title}"
c.scrolling.bar = "never"
c.statusbar.widgets = ["keypress", "url", "scroll", "progress"]

# 4. Privacy & Anti-Fingerprinting Hardening
c.content.cookies.accept = 'no-3rdparty'
c.content.canvas_reading = False
c.content.webrtc_ip_handling_policy = 'default-public-interface-only'
c.content.geolocation = False

# 5. Search Engines & Prefixes (Brave Default + Student/Dev Bangs)
c.url.searchengines = {
    'DEFAULT': 'https://search.brave.com/search?q={}',
    'w': 'https://en.wikipedia.org/wiki/Special:Search?search={}',
    'gt': 'https://translate.google.com/?sl=auto&tl=en&text={}&op=translate',
    'tr': 'https://translate.google.com/?sl=auto&tl=en&text={}&op=translate',
    'ai': 'https://claude.ai/new?q={}',
    'claude': 'https://claude.ai/new?q={}',
    'gh': 'https://github.com/search?q={}',
    'aur': 'https://aur.archlinux.org/packages?K={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
    'np': 'https://search.nixos.org/packages?channel=unstable&query={}',
    'no': 'https://search.nixos.org/options?channel=unstable&query={}',
    'nw': 'https://wiki.nixos.org/w/index.php?search={}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    'r': 'https://www.reddit.com/search/?q={}',
    'sub': 'https://www.reddit.com/r/{}',
    'zc': 'https://www.zerochan.net/search?q={}',
}

# 6. Media Offloading & Zen Mode Keybindings
config.bind('M', 'hint links spawn mpv {hint-url}')
config.bind('m', 'spawn mpv {url}')
config.bind('Z', 'hint links spawn ghostty -e yt-dlp {hint-url}')
config.bind('z', 'spawn ghostty -e yt-dlp {url}')
config.bind('xb', 'config-cycle statusbar.show always never')
config.bind('xt', 'config-cycle tabs.show multiple never')
config.bind('xx', 'config-cycle statusbar.show always never ;; config-cycle tabs.show multiple never')

# 7. Pure Subdued Noctalia Palette Mapping (Zero Hardcoded Hex)
import os
theme_file = os.path.expanduser('~/.config/qutebrowser/noctalia/colors.py')
if os.path.exists(theme_file):
    with open(theme_file, 'r') as f:
        exec(f.read(), globals())

    c.tabs.indicator.width = 0

    # Tabs (Subdued dark surfaces, NO white highlights)
    c.colors.tabs.bar.bg = surface
    c.colors.tabs.even.bg = surface_container_low
    c.colors.tabs.odd.bg = surface_container_low
    c.colors.tabs.even.fg = on_surface_variant
    c.colors.tabs.odd.fg = on_surface_variant

    # Selected Tab (Elevated container, clear text, NO red/white glare)
    c.colors.tabs.selected.even.bg = surface_container_highest
    c.colors.tabs.selected.odd.bg = surface_container_highest
    c.colors.tabs.selected.even.fg = on_surface
    c.colors.tabs.selected.odd.fg = on_surface

    # Pinned Tabs
    c.colors.tabs.pinned.even.bg = surface_container_lowest
    c.colors.tabs.pinned.odd.bg = surface_container_lowest
    c.colors.tabs.pinned.even.fg = on_surface_variant
    c.colors.tabs.pinned.selected.even.bg = surface_container_highest
    c.colors.tabs.pinned.selected.odd.bg = surface_container_highest
    c.colors.tabs.pinned.selected.even.fg = on_surface

    # Modeline / Statusbar (Dark in all modes, NO green in insert mode)
    c.colors.statusbar.normal.bg = surface
    c.colors.statusbar.normal.fg = on_surface
    c.colors.statusbar.insert.bg = surface_container_high
    c.colors.statusbar.insert.fg = on_surface
    c.colors.statusbar.caret.bg = surface_container_high
    c.colors.statusbar.caret.fg = on_surface_variant
    c.colors.statusbar.command.bg = surface_container
    c.colors.statusbar.command.fg = on_surface
    c.colors.statusbar.command.private.bg = surface_container
    c.colors.statusbar.command.private.fg = on_surface_variant
    c.colors.statusbar.passthrough.bg = surface_container_high
    c.colors.statusbar.passthrough.fg = on_surface_variant
    c.colors.statusbar.private.bg = surface
    c.colors.statusbar.private.fg = on_surface_variant
    c.colors.statusbar.progress.bg = outline_variant

    # URLs in statusbar
    c.colors.statusbar.url.fg = on_surface_variant
    c.colors.statusbar.url.hover.fg = on_surface
    c.colors.statusbar.url.success.http.fg = on_surface_variant
    c.colors.statusbar.url.success.https.fg = on_surface
    c.colors.statusbar.url.warn.fg = on_surface_variant
    c.colors.statusbar.url.error.fg = error

    # Hints (Pill container with crisp text, NO yellow box)
    c.colors.hints.bg = surface_container_highest
    c.colors.hints.fg = on_surface
    c.colors.hints.match.fg = tertiary
    c.hints.border = f"1px solid {outline_variant}"

    # Keyhint Widget (NO yellow key hints)
    c.colors.keyhint.bg = surface_container_high
    c.colors.keyhint.fg = on_surface_variant
    c.colors.keyhint.suffix.fg = on_surface

    # Completion Menu
    c.colors.completion.category.bg = surface_container_high
    c.colors.completion.category.fg = on_surface
    c.colors.completion.category.border.top = outline_variant
    c.colors.completion.category.border.bottom = outline_variant
    c.colors.completion.even.bg = surface_container_low
    c.colors.completion.odd.bg = surface_container
    c.colors.completion.fg = [on_surface, on_surface_variant, on_surface_variant]
    c.colors.completion.item.selected.bg = surface_container_highest
    c.colors.completion.item.selected.fg = on_surface
    c.colors.completion.item.selected.border.top = surface_container_highest
    c.colors.completion.item.selected.border.bottom = surface_container_highest
    c.colors.completion.item.selected.match.fg = tertiary
    c.colors.completion.match.fg = tertiary
    c.colors.completion.scrollbar.bg = surface_container
    c.colors.completion.scrollbar.fg = outline_variant

    # Context Menu
    c.colors.contextmenu.menu.bg = surface_container
    c.colors.contextmenu.menu.fg = on_surface
    c.colors.contextmenu.selected.bg = surface_container_highest
    c.colors.contextmenu.selected.fg = on_surface
    c.colors.contextmenu.disabled.bg = surface
    c.colors.contextmenu.disabled.fg = outline

    # Downloads Bar
    c.colors.downloads.bar.bg = surface
    c.colors.downloads.start.bg = surface_container_high
    c.colors.downloads.start.fg = on_surface
    c.colors.downloads.stop.bg = surface_container_highest
    c.colors.downloads.stop.fg = on_surface
    c.colors.downloads.error.bg = error_container
    c.colors.downloads.error.fg = on_error_container

    # Messages
    c.colors.messages.info.bg = surface_container
    c.colors.messages.info.fg = on_surface
    c.colors.messages.info.border = outline_variant
    c.colors.messages.warning.bg = surface_container_high
    c.colors.messages.warning.fg = on_surface
    c.colors.messages.warning.border = outline_variant
    c.colors.messages.error.bg = error_container
    c.colors.messages.error.fg = on_error_container
    c.colors.messages.error.border = error_container

    # Prompts
    c.colors.prompts.bg = surface_container_high
    c.colors.prompts.fg = on_surface
    c.colors.prompts.border = f"1px solid {outline_variant}"
    c.colors.prompts.selected.bg = surface_container_highest

    # Webpage background
    c.colors.webpage.bg = surface
