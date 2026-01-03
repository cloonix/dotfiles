# Agent Guidelines for Chezmoi Dotfiles

## Overview
This is a chezmoi-managed dotfiles repository. Files prefixed with `dot_` become hidden files (e.g., `dot_gitconfig` → `~/.gitconfig`). Files ending in `.tmpl` are chezmoi templates using Go text/template syntax.

## Build/Test Commands
- **Apply changes**: `chezmoi apply` or `chezmoi apply --dry-run` (preview)
- **Test templates**: `chezmoi execute-template < file.tmpl` - test single template file
- **Preview changes**: `chezmoi diff` - see what would change before applying
- **Validate**: `chezmoi doctor` - diagnose configuration issues
- **Status check**: `chezmoi status` - show which files would change
- **Manage files**: `chezmoi add <file>`, `chezmoi edit <file>`

## Code Style
- **Shell scripts**: Use `#!/usr/bin/env bash` shebang, include helpers via `{{ template "helpers.sh" . }}`
- **Indentation**: 2 spaces for Lua (per stylua.toml), 4 spaces for shell scripts, 2 spaces for YAML/JSON
- **Output helpers**: Use colored functions from `.chezmoitemplates/helpers.sh`: `log()`, `success()`, `warn()`, `error()`, `info()`, `progress()`, `finish()`, `failed()`
- **File naming**: `run_once_*` (runs once), `run_onchange_*` (runs when file/hash changes), `dot_*` (dotfiles), `private_*` (600 perms), `exact_*` (exact dir sync)
- **Templates**: Guard with `{{- if lookPath "cmd" -}}...{{ end -}}`, use `{{- if eq .chezmoi.os "darwin" }}` for OS checks, `{{ .chezmoi.homeDir }}` for paths
- **Error handling**: Always `exit 1` on failures, check command exit codes with `||`, provide install instructions in error messages
- **Progress pattern**: `progress "Task"; if command; then finish; else failed; exit 1; fi`
- **Comments**: Include hash triggers in onchange scripts: `# hash: {{ include "file" | sha256sum }}`

## Philosophy: Let Plugin Managers Do Their Job
- **DON'T** write scripts to install editor plugins (Lazy.nvim, vim-plug auto-install)
- **DON'T** write scripts to install tmux plugins (TPM handles this with `<prefix> + I`)
- **DON'T** write scripts to install yazi plugins (auto-installs on launch)
- **DO** write scripts for framework setup (Prezto, Homebrew packages, system config)
- **DO** let native plugin managers handle their own installation/updates
- See CHEZMOI.md for detailed explanation

## Important Rules
- **NEVER** modify README.md (owner's explicit request)
- **NEVER** auto-commit changes (per .claude/CLAUDE.md)
- **NEVER** push to remote - always wait for owner to review and push manually
- Use `.tmpl` extension for ANY file needing template variables (`.chezmoi.*`, `lookPath`, conditionals, etc.)
- Markdown: MD013 (line length) disabled per `.markdownlint-cli2.yaml`
- Always suppress stdout/stderr for background operations: `>/dev/null 2>&1`
- Keep scripts simple - prefer fewer, consolidated scripts over many small ones
