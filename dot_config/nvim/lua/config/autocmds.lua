-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Security: Disable temporary files for sensitive data (gopass, etc.)
-- neovim on Linux
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "/dev/shm/gopass*",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.undofile = false
    vim.opt_local.shada = ""
  end,
})

-- neovim on MacOS
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "/private/**/gopass**",
  callback = function()
    vim.opt_local.swapfile = false
    vim.opt_local.backup = false
    vim.opt_local.undofile = false
    vim.opt_local.shada = ""
  end,
})
