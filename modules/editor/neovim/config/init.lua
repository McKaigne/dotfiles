-- Bootstrap lazy.nvim & AstroNvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Load AstroNvim core
require("lazy").setup({
  { "AstroNvim/AstroNvim", version = "^4", import = "astronvim.plugins" },
  { import = "community" },
  { import = "plugins" },
}, {
  install = { colorscheme = { "solarized-osaka", "astrodark", "habamax" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "tohtml",
        "gzip",
        "zipPlugin",
        "netrwPlugin",
        "tarPlugin",
      },
    },
  },
})
