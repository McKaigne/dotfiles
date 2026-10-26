{ self, inputs, ... }: {
  flake.nixosModules.nixvim =
    { config, pkgs, ... }:
    {
      imports = [ inputs.nixvim.nixosModules.nixvim ];

      programs.nixvim = {
        enable = true;
        defaultEditor = false;
        nixpkgs.source = inputs.nixpkgs;

        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "mocha";
            transparent_background = true;
          };
        };

        opts = {
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          tabstop = 2;
          expandtab = true;
          smartindent = true;
          wrap = false;
          cursorline = true;
          termguicolors = true;
        };

        plugins = {
          treesitter.enable = true;
          treesitter-context.enable = true;
          lualine = {
            enable = true;
            settings = {
              options = {
                theme = "catppuccin";
                section_separators = {
                  left = { __raw = "'\\238\\130\\180'"; };
                  right = { __raw = "'\\238\\130\\182'"; };
                };
                component_separators = {
                  left = { __raw = "'\\226\\148\\130'"; };
                  right = { __raw = "'\\226\\148\\130'"; };
                };
              };
            };
          };
          noice.enable = true;
          notify.enable = true;
          mini = {
            enable = true;
            modules = {
              tabline = { };
              pairs = { };
              surround = { };
              ai = { };
            };
          };
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                timeout_ms = 500;
                lsp_fallback = true;
              };
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                sh = [ "shfmt" ];
                bash = [ "shfmt" ];
              };
            };
          };
          lsp = {
            enable = true;
            servers = {
              nixd.enable = true;
              bashls.enable = true;
              marksman.enable = true;
              taplo.enable = true;
            };
          };
          cmp = {
            enable = true;
            autoEnableSources = true;
            settings = {
              sources = [
                { name = "nvim_lsp"; }
                { name = "path"; }
                { name = "buffer"; }
              ];
            };
          };
          lspkind.enable = true;
        };
      };
    };
}
