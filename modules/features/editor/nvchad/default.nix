{ inputs, ... }: {
  flake.nixosModules.nvchad =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      home-manager.users.${user} = {
        imports = [ inputs.nix4nvchad.homeManagerModules.default ];

        programs.nvchad = {
          enable = true;
          extraPackages = with pkgs; [
            wl-clipboard
            ripgrep
            fd
          ];
          chadrcConfig = ''
            ---@type ChadrcConfig
            local M = {}
            M.base46 = {
              theme = "catppuccin",
              transparency = true,
              hl_override = {
                StatusLine = { bg = "NONE" },
                StatusLineNC = { bg = "NONE" },
                St_EmptySpace = { bg = "NONE" },
              },
            }
            M.ui = {
              transparency = true,
              statusline = {
                theme = "default",
                separator_style = "block",
              },
            }
            return M
          '';
        };
      };
    };
}
