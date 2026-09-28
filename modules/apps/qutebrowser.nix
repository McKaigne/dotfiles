{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.qutebrowser
    ];
  };
in
{
  flake.nixosModules.qutebrowser = nixosModule;

  perSystem = { pkgs, ... }:
    let
      quteConfig = pkgs.writeText "config.py" ''
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

        # 2. Functional & Dark Mode Settings
        c.auto_save.session = True
        c.session.lazy_restore = True
        c.colors.webpage.darkmode.enabled = True
        c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
        c.colors.webpage.darkmode.policy.images = 'never'
        c.content.blocking.enabled = True
        c.content.blocking.method = 'both'

        # 3. Execute Noctalia Theme into Globals (Guarantees all tokens are in scope)
        import os
        theme_file = os.path.expanduser('~/.config/qutebrowser/noctalia/colors.py')
        if os.path.exists(theme_file):
            with open(theme_file, 'r') as f:
                exec(f.read(), globals())

            # 4. Neutralize "Special Color" Overuse
            # Disables the side strip completely (eliminates the brown/red vertical line)
            c.tabs.indicator.width = 0

            # Tabs: Dark surfaces only (NO brown #3e0e0e, NO red text)
            c.colors.tabs.bar.bg = surface
            c.colors.tabs.even.bg = surface_container
            c.colors.tabs.odd.bg = surface_container
            c.colors.tabs.even.fg = on_surface
            c.colors.tabs.odd.fg = on_surface

            # Selected Tab: Elevated dark container with clear, legible text (NO bright red)
            c.colors.tabs.selected.even.bg = surface_container_highest
            c.colors.tabs.selected.odd.bg = surface_container_highest
            c.colors.tabs.selected.even.fg = on_surface_variant
            c.colors.tabs.selected.odd.fg = on_surface_variant

            # Pinned Tabs
            c.colors.tabs.pinned.even.bg = surface_container
            c.colors.tabs.pinned.odd.bg = surface_container
            c.colors.tabs.pinned.even.fg = on_surface
            c.colors.tabs.pinned.selected.even.bg = surface_container_highest
            c.colors.tabs.pinned.selected.odd.bg = surface_container_highest
            c.colors.tabs.pinned.selected.even.fg = on_surface_variant

            # Modeline / Statusbar: Dark in ALL modes (NO solid bright red in Insert mode)
            c.colors.statusbar.normal.bg = surface
            c.colors.statusbar.normal.fg = on_surface
            c.colors.statusbar.insert.bg = surface_container_high
            c.colors.statusbar.insert.fg = on_surface_variant
            c.colors.statusbar.caret.bg = surface_container_high
            c.colors.statusbar.caret.fg = on_surface_variant
            c.colors.statusbar.command.bg = surface_container
            c.colors.statusbar.command.fg = on_surface

            # Hints: Dark elevated surface pill with readable text (NO bright red or yellow)
            c.colors.hints.bg = surface_container_highest
            c.colors.hints.fg = on_surface
            c.colors.hints.match.fg = on_surface_variant
            c.hints.border = f"1px solid {outline}"
            c.hints.radius = 4
            c.hints.padding = {'top': 1, 'bottom': 1, 'left': 4, 'right': 4}

            # URLs
            c.colors.statusbar.url.fg = on_surface
            c.colors.statusbar.url.hover.fg = on_surface_variant
            c.colors.statusbar.url.success.http.fg = on_surface
            c.colors.statusbar.url.success.https.fg = on_surface
      '';

      wrappedQutebrowser = pkgs.symlinkJoin {
        name = "qutebrowser";
        paths = [ pkgs.qutebrowser ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/qutebrowser \
            --set QT_QPA_PLATFORM "wayland" \
            --set NIXOS_OZONE_WL "1" \
            --add-flags "--config-py ${quteConfig}"
        '';
      };
    in
    {
      packages.qutebrowser = wrappedQutebrowser;

      apps.qutebrowser = {
        type = "app";
        program = "${wrappedQutebrowser}/bin/qutebrowser";
        meta.description = "Qutebrowser with pure Noctalia dark-surface theming and zero special-color glare";
      };
    };
}
