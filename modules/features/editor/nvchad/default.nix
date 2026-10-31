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
                Normal = { bg = "NONE", ctermbg = "NONE" },
                NormalNC = { bg = "NONE", ctermbg = "NONE" },
                NormalFloat = { bg = "NONE", ctermbg = "NONE" },
                FloatBorder = { bg = "NONE", ctermbg = "NONE" },
                SignColumn = { bg = "NONE", ctermbg = "NONE" },
                LineNr = { bg = "NONE", ctermbg = "NONE" },
                CursorLineNr = { bg = "NONE", ctermbg = "NONE" },
                EndOfBuffer = { bg = "NONE", ctermbg = "NONE" },
                StatusLine = { bg = "NONE", ctermbg = "NONE" },
                StatusLineNC = { bg = "NONE", ctermbg = "NONE" },
                St_EmptySpace = { bg = "NONE", ctermbg = "NONE" },
              },
            }

            M.ui = {
              statusline = {
                theme = "default",
                separator_style = "round",
                modules = {
                  mode = function()
                    local modes = {
                      ["n"] = { "NOR", "St_NormalMode" },
                      ["no"] = { "NOR", "St_NormalMode" },
                      ["nov"] = { "NOR", "St_NormalMode" },
                      ["noV"] = { "NOR", "St_NormalMode" },
                      ["no"] = { "NOR", "St_NormalMode" },
                      ["niI"] = { "NOR", "St_NormalMode" },
                      ["niR"] = { "NOR", "St_NormalMode" },
                      ["niV"] = { "NOR", "St_NormalMode" },
                      ["nt"] = { "NOR", "St_NormalMode" },
                      ["ntT"] = { "NOR", "St_NormalMode" },
                      ["v"] = { "VIS", "St_VisualMode" },
                      ["vs"] = { "VIS", "St_VisualMode" },
                      ["V"] = { "V-L", "St_VisualMode" },
                      ["Vs"] = { "V-L", "St_VisualMode" },
                      [""] = { "V-B", "St_VisualMode" },
                      ["s"] = { "V-B", "St_VisualMode" },
                      ["s"] = { "SEL", "St_VisualMode" },
                      ["S"] = { "S-L", "St_VisualMode" },
                      ["9"] = { "S-B", "St_VisualMode" },
                      ["i"] = { "INS", "St_InsertMode" },
                      ["ic"] = { "INS", "St_InsertMode" },
                      ["ix"] = { "INS", "St_InsertMode" },
                      ["R"] = { "REP", "St_ReplaceMode" },
                      ["Rc"] = { "REP", "St_ReplaceMode" },
                      ["Rx"] = { "REP", "St_ReplaceMode" },
                      ["Rv"] = { "REP", "St_ReplaceMode" },
                      ["Rvc"] = { "REP", "St_ReplaceMode" },
                      ["Rvx"] = { "REP", "St_ReplaceMode" },
                      ["c"] = { "CMD", "St_CommandMode" },
                      ["cv"] = { "CMD", "St_CommandMode" },
                      ["ce"] = { "CMD", "St_CommandMode" },
                      ["r"] = { "PRM", "St_ConfirmMode" },
                      ["rm"] = { "MOR", "St_ConfirmMode" },
                      ["r?"] = { "CNF", "St_ConfirmMode" },
                      ["!"] = { "SHL", "St_TerminalMode" },
                      ["t"] = { "TRM", "St_TerminalMode" },
                    }

                    local m = vim.api.nvim_get_mode().mode
                    local current_mode = modes[m] or { "UNK", "St_NormalMode" }
                    return "%#" .. current_mode[2] .. "# " .. current_mode[1] .. " "
                  end,
                },
              },
            }

            -- Enforce transparency on theme load
            vim.api.nvim_create_autocmd("User", {
              pattern = "Base46ThemeLoaded",
              callback = function()
                local hls = { "Normal", "NormalNC", "NormalFloat", "FloatBorder", "SignColumn", "LineNr", "StatusLine", "StatusLineNC", "St_EmptySpace" }
                for _, hl in ipairs(hls) do
                  vim.api.nvim_set_hl(0, hl, { bg = "NONE", ctermbg = "NONE" })
                end
              end,
            })

            return M
          '';
        };
      };
    };
}
