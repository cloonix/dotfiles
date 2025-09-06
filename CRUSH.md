# CRUSH.md

This repository is a personal dotfiles setup (zsh, tmux, vim/neovim, yazi, ghostty). Use these commands and conventions when automating tasks here.

Commands
- Install/setup everything: ./install.sh
- Neovim plugin sync (headless): nvim --headless -c "Lazy! sync" -c "qa"
- Neovim LSP/tools install (Mason): nvim --headless -c "MasonInstallAll" -c "qa"
- Yazi plugins install/upgrade: ya pkg install && ya pkg upgrade
- Tmux plugins update (inside tmux): <prefix>U
- Vim plugins update (classic vim): vim +PlugUpdate +qall
- Markdown lint: npx -y markdownlint-cli2 "**/*.md" || markdownlint-cli2 "**/*.md"

Testing
- There is no app test suite here. For Neovim config checks, launch nvim and watch :messages for errors. For headless validation run: nvim --headless "+lua print('ok')" +qa
- To test a single Neovim plugin load path: nvim --headless -c "lua print(vim.inspect(package.loaded['plugin_name']))" -c qa

Style and conventions
- Shell: POSIX-ish with zsh as primary. Prefer portable bash/zsh syntax in scripts; avoid bashisms when not needed. Use set -euo pipefail in new scripts; minimize external deps.
- Lua (Neovim):
  - Formatting: 2 spaces; keep lines <= 100 cols. Use stylua (config in nvim/stylua.toml) where applicable.
  - Imports: use require("mod.path") locals at top; avoid globals; prefer local M = {} modules returning M.
  - Types: use LuaDoc/annotations for complex tables if helpful; otherwise keep simple.
  - Naming: snake_case for locals/fields; PascalCase for modules when mirroring plugin names; keep keymaps in nvim/lua/config.
  - Error handling: wrap plugin-dependent code in pcall(require, "name") when not ensured by Lazy; guard OS-specific paths; fail gracefully.
- Neovim (Lazy/LazyVim):
  - Plugin specs live under nvim/lua/plugins/*.lua following Lazy setup patterns; keep one concern per file.
  - Use opts = function(_, opts) ... end to extend safely; avoid mutating globals; prefer keymaps via vim.keymap.set with desc.
- Git: no secrets committed; repository uses symlink-based install—never hard-write to $HOME in scripts without backups.

AI assistant configs
- Copilot: Config present via nvim/lua/plugins/copilot.lua (CopilotChat, keymaps under <leader>C). No dedicated .github/copilot-instructions.md.
- Cursor rules: None found (.cursor/rules or .cursorrules absent). If added later, mirror key workflows here.

Notes
- Required packages: curl vim tmux git zsh keychain vivid; Neovim 0.11+ recommended.
- Leader key in Neovim is , (comma). Themes: iceberg (vim), flexoki-dark (yazi).