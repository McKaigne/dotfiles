{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "quiet" "loglevel=3" "rd.systemd.show_status=auto" "rd.udev.log_level=3" ];

  networking.hostName = "castor";
  networking.networkmanager.enable = true;

  # Hardware & Services
  hardware.bluetooth.enable = true;
  hardware.graphics.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;
  services.openssh.enable = true;

  # System-wide Cursor Environment Variables
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "16";
    HYPRCURSOR_THEME = "Bibata-Modern-Classic";
    HYPRCURSOR_SIZE = "16";
  };

  # Auto-login directly into Hyprland
  services.greetd = {
    enable = true;
    settings = {
      initial_session = {
        command = "Hyprland";
        user = "pollux";
      };
      default_session = {
        command = "Hyprland";
        user = "pollux";
      };
    };
  };

  # Enable Nushell system-wide
  programs.nushell.enable = true;

  # Direnv
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Time zone
  time.timeZone = "Asia/Manila";

  # Sound / Audio (PipeWire)
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # User account (Nushell set as default shell)
  users.users.pollux = {
    isNormalUser = true;
    shell = pkgs.nushell;
    extraGroups = [ "wheel" "networkmanager" ];
    packages = with pkgs; [
      tree
    ];
  };

  # Hyprland
  programs.hyprland.enable = true;

  # System Packages
  environment.systemPackages = with pkgs; [
    # Shell & CLI tools
    nushell
    starship
    zoxide
    carapace
    eza
    fzf
    neovim
    atuin

    # Terminals
    ghostty
    foot

    # Browser
    inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Screenshot & Media Utilities
    grim
    slurp
    wl-clipboard
    brightnessctl
    playerctl

    # Python & Scripting Tools
    python3
    direnv
    nix-direnv
    nixfmt
    shellcheck

    # Doom Emacs base & build tools
    emacs-pgtk
    git
    ripgrep
    fd
    clang
    cmake
    gnumake

    # Utilities & Cursor
    vim
    wget
    curl
    bibata-cursors
  ];

  # Fonts
  fonts.packages = with pkgs; [
    symbola
    nerd-fonts.jetbrains-mono
    nerd-fonts.symbols-only
  ];

  # Nix Settings
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "25.11";
}
