# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Common Commands 


### Installation
- `./install.sh` - Main installation script for setting up the entire dotfiles environment
- Requires zsh to be run properly and checks for required binaries before installation

### Neovim Setup
- Configuration located in `nvim/` directory
- Uses NvChad framework (v2.5) with Lazy plugin manager
- Leader key is set to `,`
- Plugins automatically sync with: `nvim --headless -c "Lazy! sync" -c "qa"`
- Language servers install with: `nvim --headless -c "MasonInstallAll" -c "qa"`

### System Requirements
Required packages: `curl vim tmux git zsh keychain vivid`
Optional: `fonts-powerline` for desktop environments
Neovim: version 0.11+ required for full configuration

## Architecture Overview

This is a personal dotfiles repository organized by application:

### Core Structure
- **nvim/** - Neovim configuration using NvChad framework with custom plugins and LSP setup
- **yazi/** - File manager configuration with custom themes (flexoki-dark) and plugins (glow, jump-to-char, mount)
- **ghostty/** - Terminal emulator configuration
- **install.sh** - Automated setup script that handles SSH keys, symlinks, and plugin installation

### Configuration Management
- Uses symlinks to connect dotfiles to their expected locations in `$HOME`
- Supports both Linux and macOS (with platform-specific Ghostty config)
- Backs up existing configurations before overwriting
- Handles GitHub SSH key setup automatically

### Key Features
- **Multi-shell support**: zsh (primary), bash, vim configurations
- **Plugin ecosystems**: 
  - Neovim: NvChad + custom plugins via Lazy
  - Tmux: TPM (Tmux Plugin Manager)
  - Zsh: Prezto framework
  - Yazi: Custom plugins for enhanced file management
- **Theme consistency**: Uses iceberg theme for vim, flexoki-dark for yazi
- **Development tools**: Git configuration, shell aliases, and productivity enhancements

The repository prioritizes a clean, symlink-based approach to dotfile management with automated installation and proper backup handling.
