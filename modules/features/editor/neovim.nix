{ self, inputs, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.myNeovim = pkgs.symlinkJoin {
      name = "neovim-wrapped";
      paths = [ pkgs.neovim ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/nvim \
          --prefix PATH : "${lib.makeBinPath [
            pkgs.gcc
            pkgs.gnumake
            pkgs.tree-sitter
            pkgs.ripgrep
            pkgs.fd
            pkgs.nodejs
            pkgs.python3
            pkgs.git
            pkgs.nixd
          ]}"
      '';
    };
  };

  flake.nixosModules.neovim = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
    system = pkgs.stdenv.hostPlatform.system;
  in
  {
    environment.systemPackages = [ self.packages.${system}.myNeovim ];

    home-manager.users.${user} = { lib, ... }: {
      # Proactively remove any legacy directory symlink before Home Manager verifies links
      home.activation.cleanLegacyNvim = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
        TARGET="$HOME/.config/nvim"
        if [ -L "$TARGET" ]; then
          rm -f "$TARGET"
        fi
      '';

      xdg.configFile."nvim/init.lua".text = ''
        vim.g.mapleader = " "
        vim.g.maplocalleader = " "

        vim.opt.relativenumber = true
        vim.opt.number = true
        vim.opt.signcolumn = "auto"
        vim.opt.wrap = false
        vim.opt.clipboard = "unnamedplus"
        vim.opt.termguicolors = true

        -- Solarized Osaka palette overrides
        local hl = vim.api.nvim_set_hl
        hl(0, "Normal", { bg = "NONE", fg = "#839496" })
        hl(0, "NormalNC", { bg = "NONE", fg = "#839496" })
        hl(0, "NormalFloat", { bg = "NONE", fg = "#839496" })
        hl(0, "FloatBorder", { bg = "NONE", fg = "#586e75" })
        hl(0, "StatusLine", { bg = "NONE", fg = "#839496" })
        hl(0, "StatusLineNC", { bg = "NONE", fg = "#586e75" })
        hl(0, "CursorLine", { bg = "NONE" })
        hl(0, "CursorLineNr", { bg = "NONE", fg = "#2aa198", bold = true })
        hl(0, "LineNr", { bg = "NONE", fg = "#586e75" })
      '';
    };
  };
}
