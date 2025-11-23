-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Fast input to exit insert mode
vim.keymap.set("i", "jf", "<Esc>", { desc = "Exit insert mode" })
vim.keymap.set("i", "fj", "<Esc>", { desc = "Exit insert mode" })

-- Write file with leader+b+s (buffer save)
vim.keymap.set("n", "<leader>bs", ":w<CR>", { desc = "Save buffer" })
