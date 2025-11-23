-- Yazi file manager integration for Neovim
-- Provides a fast, terminal-based file manager within Neovim
-- @type LazySpec

return {
  "mikavilpas/yazi.nvim",
  version = "*", -- use the latest stable version
  event = "VeryLazy", -- lazy load on VeryLazy event for faster startup
  dependencies = {
    { "nvim-lua/plenary.nvim", lazy = true }, -- utility functions for yazi
  },
  keys = {
    -- Keymappings for opening yazi in different contexts
    {
      "<leader>-",
      mode = { "n", "v" },
      "<cmd>Yazi<cr>",
      desc = "Open yazi at the current file",
    },
    {
      -- Open yazi in Neovim's working directory
      "<leader>cw",
      "<cmd>Yazi cwd<cr>",
      desc = "Open the file manager in nvim's working directory",
    },
    {
      -- Resume the last yazi session
      "<c-up>",
      "<cmd>Yazi toggle<cr>",
      desc = "Resume the last yazi session",
    },
  },
  ---@type YaziConfig | {}
  opts = {
    -- if you want to open yazi instead of netrw, set this to true
    -- see https://github.com/mikavilpas/yazi.nvim for more details
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
    },
  },
  -- Note: If open_for_directories=true, you should uncomment the init function below
  -- to prevent netrw from loading (it can cause conflicts)
  -- init = function()
  --   vim.g.loaded_netrwPlugin = 1
  -- end,
}
