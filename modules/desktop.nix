
{ inputs, ... }:
let
  desktopModule = { config, pkgs, ... }:
    let
      nnnDesktop = pkgs.makeDesktopItem {
        name = "nnn";
        desktopName = "nnn File Manager";
        comment = "Terminal File Manager";
        icon = "system-file-manager";
        exec = "${pkgs.ghostty}/bin/ghostty --class=ghostty.nnn --title=nnn -e ${pkgs.nnn}/bin/nnn -a -P p %u";
        terminal = false;
        categories = [ "System" "FileManager" ];
        mimeTypes = [ "inode/directory" "application/x-directory" ];
      };
    in
    {
      environment.sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
        NNN_OPTS = "aep";
      };

      environment.etc."xdg/direnv/direnv.toml".text = ''
        [whitelist]
        prefix = [
          "/home/${config.mainUser}/Projects",
          "/home/${config.mainUser}/projects"
        ]
      '';

      xdg.mime = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "nnn.desktop";
          "application/x-directory" = "nnn.desktop";
          "inode/mount-point" = "nnn.desktop";
          "x-scheme-handler/file" = "nnn.desktop";

          "text/plain" = "helix.desktop";
          "text/markdown" = "helix.desktop";
          "text/x-nix" = "helix.desktop";
          "application/json" = "helix.desktop";
          "application/x-yaml" = "helix.desktop";

          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-zip-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
          "application/x-gzip" = "org.gnome.FileRoller.desktop";
          "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
        };
      };

      environment.systemPackages = with pkgs; [
        # Core CLI & Search
        git
        curl
        ripgrep
        fd
        findutils
        wl-clipboard
        eza
        bat
        fetch
        file-roller
        adwaita-icon-theme
        hicolor-icon-theme
        pavucontrol
        alsa-utils
        libnotify
        direnv
        devenv
        aria2
        p7zip
        unrar
        jq

        # Diagnostics & Modern CLI Tools
        delta
        lazygit
        gh
        bottom
        dust
        procs
        tealdeer
        nnn
        nnnDesktop

        # Antigravity CLI wrapper
        (pkgs.antigravity-cli or (pkgs.writeShellScriptBin "agy" ''
          if command -v antigravity-cli &>/dev/null; then
            exec antigravity-cli "$@"
          else
            exec nix run "github:antigravity-cli/antigravity" -- "$@"
          fi
        ''))
      ];

      environment.etc."gitconfig".text = ''
        [core]
          pager = delta
          editor = hx

      [interactive]
        diffFilter = delta --color-only

      [delta]
        navigate = true
        light = false
        line-numbers = true
        side-by-side = false
        syntax-theme = "base16"
      '';

      fonts.packages = with pkgs; [
        maple-mono.NF-unhinted
        symbola
        nerd-fonts.symbols-only
      ];
    };
in
{
  flake.nixosModules.desktop = desktopModule;
}
