# Chezmoi Execution Order

## Script and Template Execution Order

Chezmoi executes scripts and templates in this order:

1. `run_once_before_*` and `run_onchange_before_*` scripts (alphabetically)
2. Files are templated and copied (e.g., `dot_*.tmpl` → `~/.file`)
3. `run_once_after_*` and `run_onchange_after_*` scripts (alphabetically)

## Script Prefixes

- `run_once_*` - Runs only once (tracks execution via state)
- `run_onchange_*` - Runs when script content or hash changes
- `before` - Runs before files are templated
- `after` - Runs after files exist and are templated

## File Naming Conventions

- `dot_*` - Becomes a hidden file (e.g., `dot_gitconfig` → `~/.gitconfig`)
- `private_*` - Sets permissions to 600 (user read/write only)
- `exact_*` - Exact directory sync (removes unmanaged files)
- `*.tmpl` - Template file using Go text/template syntax

## Hash Triggers for onchange Scripts

Include hash comments in `run_onchange_*` scripts to trigger re-execution when dependencies change:

```bash
#!/bin/zsh
# hash: {{ include "dot_config/file.conf" | sha256sum }}
# hash: {{ include ".chezmoidata/packages.yaml" | sha256sum }}
```

## Package Management

Packages are defined in `.chezmoidata/packages.yaml` with this structure:

```yaml
packages:
  darwin:
    brews:
      - "git"
      - "curl"
    casks:
      - "claude-code"
  
  linux:
    apt:
      - "tmux"
    brews:
      - "git"
    casks:
      - "claude-code"
```

OS-specific install scripts read from this file:
- `run_onchange_darwin-install-packages.sh.tmpl` - macOS (Homebrew)
- `run_onchange_linux-install-packages.sh.tmpl` - Linux (APT + Homebrew)

## Configuration Setup

This repository supports automatic config retrieval from gopass during `chezmoi init`:

### Config Profiles in Gopass

Store configs at these gopass paths:
- `config/chezmoi/basic.toml` - Minimal setup for any machine
- `config/chezmoi/dev.toml` - Full dev environment (Linux)
- `config/chezmoi/mac.toml` - macOS workstation

### During `chezmoi init`

On first-time setup, you'll be prompted to select a config profile:
1. Script checks if `~/.config/chezmoi/chezmoi.toml` already exists (skip if exists)
2. If gopass is available, prompts: "Select config profile [1-3] (or press Enter to skip)"
3. Retrieves selected config from gopass automatically
4. If gopass unavailable or skipped, falls back to interactive prompts

**The config file contains template variables used throughout the dotfiles.**

## Important: Init vs Apply

- **`chezmoi init <repo>`** - First-time setup on brand new machine
  - Clones repository
  - Runs `run_once_before` scripts (including config retrieval from gopass)
  - **Note**: If config is retrieved from gopass, run `chezmoi apply` afterward to complete setup
  
- **`chezmoi apply`** - Apply configuration (use after init or for updates)
  - Uses existing `~/.config/chezmoi/chezmoi.toml`
  - Templates all files
  - Runs all scripts
  - Use this for normal operations and after config retrieval

**Recommended workflow for new machine:**
```bash
# First time - clone and get config from gopass
chezmoi init cloonix/dotfiles
# Select profile when prompted (e.g., "3" for mac)

# Then apply with the retrieved config
chezmoi apply
```

## Scripts in This Repository

### Phase 1: Before Scripts (run before files are templated)

#### `run_once_before_10-setup-config-from-gopass.sh.tmpl`
**Interactive config retrieval from gopass.** Prompts for config profile (basic/dev/mac) and retrieves it from gopass. Skips if:
- Config file already exists at `~/.config/chezmoi/chezmoi.toml`
- Gopass is not available
- User chooses to skip (will use interactive prompts instead)

#### `run_once_before_20-setup-ssh.sh.tmpl`
Interactive SSH key setup. Prompts for GitHub username and downloads public keys from `https://github.com/<username>.keys` to `~/.ssh/authorized_keys`. Backs up existing keys and sets proper permissions (700/600).

### Phase 2: File Templating

All `dot_*`, `private_*`, and template files are processed and copied to home directory. This includes:
- Configuration files (`.zshrc`, `.vimrc`, `.tmux.conf`, etc.)
- Application configs (nvim, yazi, k9s, etc.)

### Phase 3: After Scripts (run after files exist)

#### `run_onchange_darwin-install-packages.sh.tmpl`
Installs Homebrew packages on macOS. Automatically installs Homebrew if not present. Reads from `.chezmoidata/packages.yaml` (`packages.darwin.brews` and `packages.darwin.casks`). Re-runs when packages.yaml changes.

#### `run_onchange_linux-install-packages.sh.tmpl`
Installs packages on Linux. Automatically installs Homebrew if not present. First installs APT packages (`packages.linux.apt`), then Homebrew packages (`packages.linux.brews` and `packages.linux.casks`). Re-runs when packages.yaml changes.

#### `run_onchange_after_15-configure-frameworks.sh.tmpl`
**Framework configuration** that sets up and configures essential tools:
1. **Zsh Prezto** - Clones or updates the Prezto framework and its submodules
2. **Gopass settings** - Configures gopass preferences (safecontent, autoclip, notifications) and git push remotes

Re-runs when the script content changes.

#### `run_after_25-copy-gopass-files-local.sh.tmpl`
**Optional:** Copies configuration files from gopass to local destinations. Reads from `~/.config/chezmoi/gopass-files-local.conf` (format: `gopass_path:destination`).

- Runs on every `chezmoi apply` if gopass and config file exist
- Prompts once if any target files already exist (overwrite/skip/quit)
- Sets all copied files to 600 permissions (sensitive data)
- Config file is templated based on OS (darwin/linux) with different paths per OS
- SSH keys are commented out on macOS, enabled on Linux by default

This is separate from `setup-chezmoi-remote.sh` which handles remote machine setup via SSH.

#### `run_once_after_90-finalize.sh.tmpl`
**Final setup** that:
1. Changes default shell to zsh (with `chsh -s`)
2. Displays completion message with system info
3. Lists manual post-install steps for plugin managers

## Manual Post-Install Steps

After `chezmoi apply` completes, perform these one-time tasks:

### Neovim
Lazy.nvim auto-syncs plugins on first launch:
```bash
nvim
# Wait for Lazy to complete, then :qa
```

### Vim (fallback systems)
vim-plug auto-installs on first vim launch (if auto-install in .vimrc is enabled):
```bash
vim
# Or manually run: :PlugInstall
```

### Tmux
Install TPM plugins with keyboard shortcut:
```bash
tmux
# Press: <prefix> + I (capital I)
```

### Yazi
Plugins auto-install on first launch:
```bash
yazi
# Plugins install automatically
```

### Prezto
Prezto manages its own runcom files. After initial setup, these files are auto-linked:
- `.zlogin`, `.zlogout`, `.zprofile`, `.zshenv` (managed by Prezto)
- `.zshrc`, `.zpreztorc` (managed by chezmoi)

## Common Commands

- `chezmoi apply` - Apply all changes
- `chezmoi apply --dry-run` - Preview changes without applying
- `chezmoi diff` - Show differences between source and target
- `chezmoi status` - Show which files would change
- `chezmoi execute-template < file.tmpl` - Test template rendering
- `chezmoi doctor` - Diagnose configuration issues

## Philosophy

This setup follows the **plugin manager principle**: Let native tools handle their own installation and updates. Scripts only handle:
1. Framework setup (Prezto, Homebrew packages)
2. Initial configuration
3. System-level changes (shell, SSH)

Plugin managers (Lazy.nvim, vim-plug, TPM, Yazi) handle their own plugins automatically.
