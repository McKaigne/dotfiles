---@type LazySpec
return {
  {
    "Amansingh-afk/milli.nvim",
    lazy = false,
    opts = {
      screensaver = false,
    },
  },
  {
    "goolord/alpha-nvim",
    dependencies = { "Amansingh-afk/milli.nvim" },
    opts = function(_, opts)
      local milli = require("milli")
      local ok, splash = pcall(milli.load, { splash = "shader" })
      if not ok or not splash or not splash.frames or #splash.frames == 0 then
        ok, splash = pcall(milli.load, { splash = "fire" })
      end

      if ok and splash and splash.frames and #splash.frames > 0 then
        opts.section.header.val = splash.frames[1]
      end

      -- Initial placeholder rows centered by Alpha
      opts.section.buttons.val = {
        {
          type = "text",
          val = "  ❯ 󰝒  New File       SPC n           󰈬  Find Word      SPC f w  ",
          opts = { position = "center", hl = "AlphaButton" },
        },
        {
          type = "text",
          val = "    󰈞  Find File      SPC f f         󰃁  Bookmarks      SPC f '  ",
          opts = { position = "center", hl = "AlphaButton" },
        },
        {
          type = "text",
          val = "      Recents        SPC f o         󰦛  Last Session   SPC S l  ",
          opts = { position = "center", hl = "AlphaButton" },
        },
      }

      -- Compact vertical layout ensuring complete viewport fit
      opts.layout = {
        { type = "padding", val = 1 },
        opts.section.header,
        { type = "padding", val = 1 },
        opts.section.buttons,
        { type = "padding", val = 1 },
        opts.section.footer,
      }
      return opts
    end,
    config = function(plugin, opts)
      require("alpha").setup(opts)

      -- 2D Grid Navigator with hardware cursor suppression and invariant centering
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "alpha",
        callback = function(ev)
          local buf = ev.buf

          -- Hide the terminal hardware cursor while on the Alpha dashboard
          io.write("\x1b[?25l")

          -- Restore the terminal hardware cursor when leaving the dashboard
          local function restore_cursor()
            io.write("\x1b[?25h")
          end
          vim.api.nvim_create_autocmd({ "BufLeave", "VimLeavePre" }, {
            buffer = buf,
            callback = restore_cursor,
            once = true,
          })

          local items = {
            {
              left = { icon = "󰝒", label = "New File", chord = "SPC n", act = function() vim.cmd "ene | startinsert" end },
              right = { icon = "󰈬", label = "Find Word", chord = "SPC f w", act = function() require("telescope.builtin").live_grep() end },
            },
            {
              left = { icon = "󰈞", label = "Find File", chord = "SPC f f", act = function() require("telescope.builtin").find_files() end },
              right = { icon = "󰃁", label = "Bookmarks", chord = "SPC f '", act = function() require("telescope.builtin").marks() end },
            },
            {
              left = { icon = "", label = "Recents", chord = "SPC f o", act = function() require("telescope.builtin").oldfiles() end },
              right = { icon = "󰦛", label = "Last Session", chord = "SPC S l", act = function() pcall(require("resession").load, "Last Session") end },
            },
          }

          local cur_r = 1
          local cur_c = 1

          local function get_button_line_indices()
            local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
            local indices = {}
            for i, line in ipairs(lines) do
              if line:find("New File", 1, true) or line:find("Find File", 1, true) or line:find("Recents", 1, true) then
                table.insert(indices, i)
              end
            end
            return indices
          end

          local function redraw_grid()
            local row_indices = get_button_line_indices()
            if #row_indices < 3 then return end

            -- Calculate mathematical center margin to prevent compounding rightward drift
            local total_content_width = 57
            local win_w = vim.api.nvim_win_get_width(0)
            local pad_len = math.max(0, math.floor((win_w - total_content_width) / 2))
            local pad = string.rep(" ", pad_len)

            local new_lines = {}
            for r = 1, 3 do
              local row_data = items[r]
              local p_left = (r == cur_r and cur_c == 1) and "❯ " or "  "
              local p_right = (r == cur_r and cur_c == 2) and "❯ " or "  "

              local left_col = string.format("%s%s  %-14s %-7s", p_left, row_data.left.icon, row_data.left.label, row_data.left.chord)
              local right_col = string.format("%s%s  %-14s %-7s", p_right, row_data.right.icon, row_data.right.label, row_data.right.chord)

              table.insert(new_lines, pad .. left_col .. "       " .. right_col)
            end

            vim.bo[buf].modifiable = true
            for r = 1, 3 do
              vim.api.nvim_buf_set_lines(buf, row_indices[r] - 1, row_indices[r], false, { new_lines[r] })
            end
            vim.bo[buf].modifiable = false
          end

          local function map(key, fn)
            vim.keymap.set("n", key, fn, { buffer = buf, nowait = true, silent = true })
          end

          map("h", function() cur_c = 1; redraw_grid() end)
          map("l", function() cur_c = 2; redraw_grid() end)
          map("j", function() cur_r = (cur_r % 3) + 1; redraw_grid() end)
          map("k", function() cur_r = cur_r == 1 and 3 or (cur_r - 1); redraw_grid() end)
          map("<Left>", function() cur_c = 1; redraw_grid() end)
          map("<Right>", function() cur_c = 2; redraw_grid() end)
          map("<Down>", function() cur_r = (cur_r % 3) + 1; redraw_grid() end)
          map("<Up>", function() cur_r = cur_r == 1 and 3 or (cur_r - 1); redraw_grid() end)

          map("<CR>", function()
            restore_cursor()
            local item = items[cur_r]
            local target = cur_c == 1 and item.left or item.right
            target.act()
          end)
          map("<Space>", function()
            restore_cursor()
            local item = items[cur_r]
            local target = cur_c == 1 and item.left or item.right
            target.act()
          end)

          vim.schedule(redraw_grid)
        end,
      })

      vim.schedule(function()
        pcall(function()
          require("milli").alpha({ splash = "shader", loop = true })
        end)
      end)
    end,
  },
}
