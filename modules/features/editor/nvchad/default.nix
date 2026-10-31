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
            }
            M.ui = {
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
