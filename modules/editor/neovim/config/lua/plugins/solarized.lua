---@type LazySpec
return {
  {
    "craftzdog/solarized-osaka.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        sidebars = "transparent",
        floats = "transparent",
      },
      on_highlights = function(hl, c)
        -- 1. Canvas & Window Glassmorphism
        hl.Normal = { bg = "NONE", fg = c.base0 }
        hl.NormalNC = { bg = "NONE", fg = c.base0 }
        hl.NormalFloat = { bg = "NONE", fg = c.base0 }
        hl.FloatBorder = { bg = "NONE", fg = c.base01 }
        hl.FloatTitle = { bg = "NONE", fg = c.cyan, bold = true }

        -- 2. Zero-Distraction CursorLine
        hl.CursorLine = { bg = "NONE" }
        hl.CursorLineNr = { bg = "NONE", fg = c.cyan, bold = true }
        hl.LineNr = { bg = "NONE", fg = c.base01 }
        hl.SignColumn = { bg = "NONE" }

        -- 3. Winbar / Header Ribbon Transparency
        hl.WinBar = { bg = "NONE", fg = c.base0 }
        hl.WinBarNC = { bg = "NONE", fg = c.base01 }

        -- 4. Statusline & Tabline (Heirline) Seamless Blending
        hl.StatusLine = { bg = "NONE", fg = c.base0 }
        hl.StatusLineNC = { bg = "NONE", fg = c.base01 }
        hl.TabLine = { bg = "NONE", fg = c.base01 }
        hl.TabLineFill = { bg = "NONE" }
        hl.TabLineSel = { bg = "NONE", fg = c.cyan, bold = true }

        -- 5. Unified Neo-tree Explorer & Tab Strip
        hl.NeoTreeNormal = { bg = "NONE", fg = c.base0 }
        hl.NeoTreeNormalNC = { bg = "NONE", fg = c.base0 }
        hl.NeoTreeEndOfBuffer = { bg = "NONE", fg = c.base03 }
        hl.NeoTreeWinSeparator = { bg = "NONE", fg = c.base02 }
        hl.NeoTreeTabBar = { bg = "NONE" }
        hl.NeoTreeTabActive = { bg = "NONE", fg = c.cyan, bold = true }
        hl.NeoTreeTabInactive = { bg = "NONE", fg = c.base01 }
        hl.NeoTreeTabSeparatorActive = { bg = "NONE", fg = c.base02 }
        hl.NeoTreeTabSeparatorInactive = { bg = "NONE", fg = c.base02 }

        -- 6. Auto-Completion Popups (nvim-cmp / Pmenu)
        hl.Pmenu = { bg = "NONE", fg = c.base0 }
        hl.PmenuSel = { bg = c.base02, fg = c.cyan, bold = true }
        hl.PmenuSbar = { bg = "NONE" }
        hl.PmenuThumb = { bg = c.base01 }

        -- 7. Telescope Pickers Glassmorphism
        hl.TelescopeNormal = { bg = "NONE", fg = c.base0 }
        hl.TelescopeBorder = { bg = "NONE", fg = c.base01 }
        hl.TelescopePromptNormal = { bg = "NONE", fg = c.base0 }
        hl.TelescopePromptBorder = { bg = "NONE", fg = c.cyan }
        hl.TelescopePromptPrefix = { fg = c.cyan, bold = true }
        hl.TelescopeResultsNormal = { bg = "NONE", fg = c.base0 }
        hl.TelescopeResultsBorder = { bg = "NONE", fg = c.base01 }
        hl.TelescopePreviewNormal = { bg = "NONE", fg = c.base0 }
        hl.TelescopePreviewBorder = { bg = "NONE", fg = c.base01 }

        -- 8. Diagnostic Virtual Text
        hl.DiagnosticVirtualTextError = { bg = "NONE", fg = c.red }
        hl.DiagnosticVirtualTextWarn = { bg = "NONE", fg = c.yellow }
        hl.DiagnosticVirtualTextInfo = { bg = "NONE", fg = c.blue }
        hl.DiagnosticVirtualTextHint = { bg = "NONE", fg = c.cyan }
      end,
    },
  },
  {
    "AstroNvim/astroui",
    opts = {
      colorscheme = "solarized-osaka",
      highlights = {
        init = function()
          return {
            -- Clear all solid backgrounds from AstroNvim Heirline components
            Heirline = { bg = "NONE" },
            HeirlineInactive = { bg = "NONE" },
            HeirlineNormal = { bg = "NONE" },
            HeirlineInsert = { bg = "NONE" },
            HeirlineVisual = { bg = "NONE" },
            HeirlineReplace = { bg = "NONE" },
            HeirlineCommand = { bg = "NONE" },
            HeirlineTerminal = { bg = "NONE" },
            -- Winbar (Header Ribbon)
            HeirlineWinbar = { bg = "NONE" },
            HeirlineWinbarInactive = { bg = "NONE" },
            -- Tabline (Bufferline)
            TabLine = { bg = "NONE" },
            TabLineFill = { bg = "NONE" },
            TabLineSel = { bg = "NONE" },
            -- Section Badges
            HeirlineSection = { bg = "NONE" },
          }
        end,
      },
    },
  },
}
