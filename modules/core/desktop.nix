{ inputs, ... }:
let
  desktopModule = { pkgs, ... }:
    let
      helixDesktop = pkgs.makeDesktopItem {
        name = "helix";
        desktopName = "Helix";
        comment = "Helix Modal Text Editor";
        icon = "helix";
        exec = "ghostty -e hx %F";
        terminal = false;
        categories = [ "Development" "TextEditor" ];
        mimeTypes = [
          "text/plain"
          "text/x-c"
          "text/x-c++src"
          "text/x-c++hdr"
          "text/x-csrc"
          "text/x-chdr"
          "text/x-rust"
          "text/x-elixir"
          "application/json"
          "text/markdown"
          "text/x-python"
          "text/x-go"
          "text/x-nix"
          "application/x-yaml"
          "text/x-cmake"
        ];
      };
    in
    {
      environment.variables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };

      environment.sessionVariables = {
        EDITOR = "hx";
        VISUAL = "hx";
      };

      xdg.mime = {
        enable = true;
        defaultApplications = {
          # Dolphin as default GUI file manager
          "inode/directory" = [ "org.kde.dolphin.desktop" "superfile.desktop" ];
          "application/x-directory" = [ "org.kde.dolphin.desktop" "superfile.desktop" ];
          "inode/mount-point" = [ "org.kde.dolphin.desktop" "superfile.desktop" ];
          "x-scheme-handler/file" = [ "org.kde.dolphin.desktop" "superfile.desktop" ];

          # Universal code & text files -> Helix
          "text/plain" = "helix.desktop";
          "text/x-c" = "helix.desktop";
          "text/x-c++src" = "helix.desktop";
          "text/x-c++hdr" = "helix.desktop";
          "text/x-csrc" = "helix.desktop";
          "text/x-chdr" = "helix.desktop";
          "text/x-rust" = "helix.desktop";
          "text/x-elixir" = "helix.desktop";
          "application/json" = "helix.desktop";
          "text/markdown" = "helix.desktop";
          "text/x-nix" = "helix.desktop";
          "application/x-yaml" = "helix.desktop";

          # Archives
          "application/zip" = "org.gnome.FileRoller.desktop";
          "application/x-zip-compressed" = "org.gnome.FileRoller.desktop";
          "application/x-tar" = "org.gnome.FileRoller.desktop";
          "application/x-compressed-tar" = "org.gnome.FileRoller.desktop";
          "application/x-gzip" = "org.gnome.FileRoller.desktop";
          "application/x-bzip2" = "org.gnome.FileRoller.desktop";
          "application/x-xz" = "org.gnome.FileRoller.desktop";
          "application/x-7z-compressed" = "org.gnome.FileRoller.desktop";
          "application/vnd.rar" = "org.gnome.FileRoller.desktop";
        };
      };

      environment.systemPackages = with pkgs; [
        helixDesktop
        git
        curl
        ripgrep
        fd
        findutils
        wl-clipboard
        eza
        bat
        fetch
        antigravity-cli
        adwaita-icon-theme
        hicolor-icon-theme
        pavucontrol
        alsa-utils
        libnotify

        # Development Tooling & Highlighting
        nnn
        direnv
        pkgs.devenv
        delta

        # Downloaders & Extractors
        yt-dlp
        aria2
        p7zip
        unrar
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
        maple-mono.truetype
        symbola
        nerd-fonts.symbols-only
      ];
    };
in
{
  flake.nixosModules.desktop = desktopModule;
  flake.nixosModules.castorConfiguration = desktopModule;
}