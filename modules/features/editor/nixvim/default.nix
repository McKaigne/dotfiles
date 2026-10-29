{ self, inputs, ... }: {
  flake.nixosModules.nixvim =
    { config, pkgs, ... }:
    {
      imports = [ inputs.nixvim.nixosModules.nixvim ];

      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;
        nixpkgs.source = inputs.nixpkgs;

        extraPackages = with pkgs; [
          # Formatters & Linters
          nixfmt
          shfmt
          prettier
          jq
          ruff
          clang-tools
          rustfmt
          dart

          # Language Servers
          marksman
          nixd
          taplo
          yaml-language-server
          bash-language-server
          shellcheck
          pyright
          rust-analyzer
          vscode-langservers-extracted # Provides vscode-html-language-server & vscode-json-languageserver
          lazygit
        ];

        colorschemes.catppuccin = {
          enable = true;
          settings = {
            flavour = "mocha";
            transparent_background = true;
            integrations = {
              bufferline = true;
              cmp = true;
              gitsigns = true;
              illuminate = true;
              indent_blankline.enabled = true;
              mini.enabled = true;
              neotree = true;
              telescope.enabled = true;
              treesitter = true;
              treesitter_context = true;
              which_key = true;
            };
          };
        };

        opts = {
          number = true;
          relativenumber = true;
          shiftwidth = 2;
          tabstop = 2;
          softtabstop = 2;
          expandtab = true;
          smartindent = true;
          autoindent = true;
          wrap = false;
          cursorline = true;
          termguicolors = true;
          scrolloff = 8;
          sidescrolloff = 8;
          mouse = "a";
          signcolumn = "yes";
          updatetime = 50;
          timeoutlen = 300;
          ignorecase = true;
          smartcase = true;
          incsearch = true;
          hlsearch = true;
          splitbelow = true;
          splitright = true;
          undofile = true;
          swapfile = false;
          backup = false;
        };

        globals = {
          mapleader = " ";
          maplocalleader = " ";
        };

        keymaps = [
          # Window Navigation
          { mode = "n"; key = "<C-h>"; action = "<C-w>h"; options.desc = "Focus left window"; }
          { mode = "n"; key = "<C-j>"; action = "<C-w>j"; options.desc = "Focus down window"; }
          { mode = "n"; key = "<C-k>"; action = "<C-w>k"; options.desc = "Focus up window"; }
          { mode = "n"; key = "<C-l>"; action = "<C-w>l"; options.desc = "Focus right window"; }

          # Window Splits
          { mode = "n"; key = "<leader>sv"; action = "<C-w>v"; options.desc = "Split window vertically"; }
          { mode = "n"; key = "<leader>sh"; action = "<C-w>s"; options.desc = "Split window horizontally"; }
          { mode = "n"; key = "<leader>se"; action = "<C-w>="; options.desc = "Make splits equal size"; }
          { mode = "n"; key = "<leader>sx"; action = "<cmd>close<CR>"; options.desc = "Close current split"; }

          # Buffer Navigation
          { mode = "n"; key = "<S-h>"; action = "<cmd>bprevious<CR>"; options.desc = "Previous buffer"; }
          { mode = "n"; key = "<S-l>"; action = "<cmd>bnext<CR>"; options.desc = "Next buffer"; }
          { mode = "n"; key = "<leader>bd"; action = "<cmd>bdelete<CR>"; options.desc = "Delete buffer"; }

          # Visual Line Movement
          { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.desc = "Move line down"; }
          { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.desc = "Move line up"; }

          # Indentation Preservation
          { mode = "v"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
          { mode = "v"; key = ">"; action = ">gv"; options.desc = "Indent right"; }

          # Clear Search Highlight
          { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<CR>"; options.desc = "Clear search highlight"; }

          # Code Formatting
          {
            mode = [ "n" "v" ];
            key = "<leader>cf";
            action = "<cmd>lua require('conform').format({ async = true, lsp_fallback = true })<CR>";
            options.desc = "Format buffer or selection";
          }

          # File Explorer & History
          { mode = "n"; key = "<leader>e"; action = "<cmd>Neotree toggle<CR>"; options.desc = "Toggle NeoTree explorer"; }
          { mode = "n"; key = "<leader>u"; action = "<cmd>UndotreeToggle<CR>"; options.desc = "Toggle UndoTree"; }
          { mode = "n"; key = "<leader>gg"; action = "<cmd>LazyGit<CR>"; options.desc = "Open LazyGit"; }

          # Telescope Finders
          { mode = "n"; key = "<leader>ff"; action = "<cmd>Telescope find_files<CR>"; options.desc = "Find files"; }
          { mode = "n"; key = "<leader>fg"; action = "<cmd>Telescope live_grep<CR>"; options.desc = "Live grep"; }
          { mode = "n"; key = "<leader>fb"; action = "<cmd>Telescope buffers<CR>"; options.desc = "Find buffers"; }
          { mode = "n"; key = "<leader>fh"; action = "<cmd>Telescope help_tags<CR>"; options.desc = "Help tags"; }
          { mode = "n"; key = "<leader>fr"; action = "<cmd>Telescope oldfiles<CR>"; options.desc = "Recent files"; }

          # Trouble Diagnostics Triage
          { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle<CR>"; options.desc = "Diagnostics (Trouble)"; }
          { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<CR>"; options.desc = "Buffer Diagnostics (Trouble)"; }
          { mode = "n"; key = "<leader>xt"; action = "<cmd>Trouble todo toggle<CR>"; options.desc = "Todo comments (Trouble)"; }
        ];

        autoCmd = [
          {
            event = [ "TextYankPost" ];
            callback = {
              __raw = ''
                function()
                  vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 40 })
                end
              '';
            };
          }
          {
            event = [ "User" ];
            pattern = [ "DirenvLoaded" ];
            callback = {
              __raw = ''
                function()
                  -- When devenv/direnv exports new paths inside Neovim, restart LSP servers to bind project toolchains
                  vim.schedule(function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    if vim.api.nvim_buf_is_valid(bufnr) and vim.bo[bufnr].buftype == "" then
                      vim.cmd("silent! LspRestart")
                    end
                  end)
                end
              '';
            };
          }
        ];

        plugins = {
          # Native Direnv Integration
          direnv.enable = true;

          # Completion & Snippets
          cmp = {
            enable = true;
            autoEnableSources = true;
            settings = {
              sources = [
                { name = "nvim_lsp"; }
                { name = "luasnip"; }
                { name = "path"; }
                { name = "buffer"; }
              ];
              mapping = {
                "<C-Space>" = "cmp.mapping.complete()";
                "<C-e>" = "cmp.mapping.abort()";
                "<CR>" = "cmp.mapping.confirm({ select = true })";
                "<Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_next_item() else fallback() end end, { 'i', 's' })";
                "<S-Tab>" = "cmp.mapping(function(fallback) if cmp.visible() then cmp.select_prev_item() else fallback() end end, { 'i', 's' })";
              };
            };
          };
          luasnip.enable = true;
          lspkind = {
            enable = true;
            settings = {
              mode = "symbol_text";
            };
          };
          nvim-autopairs.enable = true;

          # UI Elements & Context
          web-devicons.enable = true;
          bufferline = {
            enable = true;
            settings = {
              options = {
                diagnostics = "nvim_lsp";
                separator_style = "thin";
                show_close_icon = false;
                show_buffer_close_icons = false;
              };
            };
          };
          lualine = {
            enable = true;
            settings = {
              options = {
                theme = "catppuccin";
                globalstatus = true;
              };
            };
          };
          indent-blankline.enable = true;
          todo-comments.enable = true;
          fidget.enable = true;
          navic.enable = true;

          # Treesitter & Navigation
          treesitter = {
            enable = true;
            settings = {
              highlight.enable = true;
              indent.enable = true;
            };
          };
          treesitter-context.enable = true;
          neo-tree = {
            enable = true;
            settings = {
              close_if_last_window = true;
              popup_border_style = "rounded";
            };
          };
          undotree.enable = true;
          illuminate.enable = true;

          mini = {
            enable = true;
            modules = {
              surround = { };
              ai = { };
              comment = { };
            };
          };

          # Git Integration
          gitsigns = {
            enable = true;
            settings = {
              current_line_blame = false;
              signs = {
                add = { text = "│"; };
                change = { text = "│"; };
                delete = { text = "_"; };
                topdelete = { text = "‾"; };
                changedelete = { text = "~"; };
              };
            };
          };
          lazygit.enable = true;

          # Pickers & Utilities
          telescope = {
            enable = true;
            settings = {
              defaults = {
                layout_strategy = "horizontal";
                layout_config = {
                  prompt_position = "top";
                };
                sorting_strategy = "ascending";
              };
            };
          };
          which-key.enable = true;
          toggleterm = {
            enable = true;
            settings = {
              direction = "float";
              open_mapping = "[[<c-\\>]]";
              float_opts = {
                border = "curved";
              };
            };
          };
          trouble.enable = true;

          # LSP Configuration: Polyglot Support
          lsp = {
            enable = true;
            keymaps = {
              diagnostic = {
                "[d" = "goto_prev";
                "]d" = "goto_next";
                "<leader>d" = "open_float";
              };
              lspBuf = {
                "K" = "hover";
                "gd" = "definition";
                "gD" = "declaration";
                "gi" = "implementation";
                "gr" = "references";
                "<leader>ca" = "code_action";
                "<leader>rn" = "rename";
              };
            };
            servers = {
              nixd.enable = true;
              bashls.enable = true;
              marksman.enable = true;
              taplo.enable = true;
              yamlls.enable = true;
              jsonls.enable = true;
              html.enable = true;
              gopls.enable = true;
              rust_analyzer = {
                enable = true;
                installCargo = false;
                installRustc = false;
              };

              # Flutter / Dart
              dartls.enable = true;

              # Python
              pyright.enable = true;
              ruff.enable = true;

              # C / C++
              clangd.enable = true;
            };
          };

          # Automatic Code Formatting
          conform-nvim = {
            enable = true;
            settings = {
              format_on_save = {
                timeout_ms = 1000;
                lsp_fallback = true;
              };
              formatters_by_ft = {
                nix = [ "nixfmt" ];
                sh = [ "shfmt" ];
                bash = [ "shfmt" ];
                markdown = [ "prettier" ];
                yaml = [ "prettier" ];
                json = [ "jq" ];
                html = [ "prettier" ];
                python = [ "ruff_format" "ruff_fix" ];
                c = [ "clang-format" ];
                cpp = [ "clang-format" ];
                rust = [ "rustfmt" ];
                dart = [ "dart_format" ];
              };
            };
          };
        };
      };
    };
}
