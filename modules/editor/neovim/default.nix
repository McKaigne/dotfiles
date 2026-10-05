{ config, pkgs, lib, ... }:
let
  user = config.mainUser;
in
{
  environment.systemPackages = with pkgs; [
    neovim
    # Build toolchains for Treesitter parsers & native extensions
    gcc
    gnumake
    tree-sitter
    # High-performance search & file navigation
    ripgrep
    fd
    # Runtime environments for language servers
    nodejs
    python3
    # Utilities
    git
    unzip
    curl
    wget
  ];

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  home-manager.users.${user} = { config, ... }: {
    xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "/etc/nixos/modules/editor/neovim/config";
  };
}
