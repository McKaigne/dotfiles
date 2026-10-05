---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    opts = {
      auto_install = true,
      ensure_installed = {
        "bash",
        "c",
        "cpp",
        "html",
        "json",
        "kdl",
        "lua",
        "markdown",
        "markdown_inline",
        "nix",
        "python",
        "rust",
        "toml",
        "vim",
        "vimdoc",
        "yaml",
      },
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "master",
  },
}
