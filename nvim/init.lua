vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = ","

-- Fast input to exit insert mode
vim.keymap.set("i", "jf", "<Esc>")
vim.keymap.set("i", "fj", "<Esc>")

-- Save file
vim.keymap.set("n", "<leader>w", ":w<CR>")
-- Save session/windows (super save)
vim.keymap.set("n", "<leader>s", ":mksession<CR>")
-- Close/delete buffer
vim.keymap.set("n", "<leader>q", ":bd<CR>")
-- Close Neovim
vim.keymap.set("n", "<leader>Q", ":qall!<CR>")

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "autocmds"

vim.schedule(function()
  require "mappings"
end)
