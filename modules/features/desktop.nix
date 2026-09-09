{ self, inputs, ... }: {
  flake.nixosModules.desktop = { pkgs, lib, ... }: {
    security.pam.services.hyprlock = { };

    nixpkgs.config.allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "antigravity-cli"
        "zed-editor"
      ];

    environment.systemPackages = with pkgs; [
      bat
      fd
      ripgrep
      btop
      cava
      yazi
      fetch
      zoxide
      antigravity-cli

      hyprlock
      overskride
      bluez
      bluez-tools

      git
      ghostty
      foot
      grim
      slurp
      wl-clipboard
      brightnessctl
      playerctl
      vim
      wget
      curl

      # Terminal emulation bridges for GLib/GIO/Thunar
      (writeShellScriptBin "xterm" ''exec ghostty "$@"'')
      (writeShellScriptBin "x-terminal-emulator" ''exec ghostty "$@"'')

      # Audio control & diagnostics
      pavucontrol
      alsa-utils

      # Media & Content Creation
      kdePackages.kdenlive
      mpv
      obs-studio

      # Editors & Multiplexer
      helix
      zed-editor
      zathura
      feh
      tmux
      tmuxPlugins.dotbar
    ];

    fonts.packages = with pkgs; [
      maple-mono.NF-unhinted
      maple-mono.truetype
      symbola
      nerd-fonts.symbols-only
    ];
  };
}