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

This repository supports two ways to create `~/.config/chezmoi/chezmoi.toml`:

### Method 1: Interactive Prompts (`.chezmoi.toml.tmpl`)
On **first-time setup**, `chezmoi init` will prompt for all required values:
- Personal email address
- GPG signing key ID
- Full name
- GitHub/GitLab emails
- Gopass repository URLs
- Context7 API key

These values are stored in `~/.config/chezmoi/chezmoi.toml` (gitignored).

### Method 2: From Gopass (optional)
If you have the config stored in gopass at `config/chezmoi.toml`, the script will automatically copy it during `chezmoi apply`. This is useful for quickly setting up new machines without interactive prompts.

**Both methods produce the same result.** The config file contains template variables used throughout the dotfiles.

## Important: Init vs Apply

- **`chezmoi init`** - First-time setup (prompts for config, clones repo)
  - Use on: Brand new system
  - Creates: `~/.config/chezmoi/chezmoi.toml`
  - Prompts: Yes (unless gopass provides config)

- **`chezmoi apply`** - Update existing setup (no prompts)
  - Use on: System with existing config
  - Uses: Existing `~/.config/chezmoi/chezmoi.toml`
  - Prompts: No

**If you already have config, use `chezmoi apply` not `chezmoi init`.**

## Scripts in This Repository

### Phase 1: Before Scripts (run before files are templated)

#### `run_once_before_20-setup-ssh.sh.tmpl`
Interactive SSH key setup. Prompts for GitHub username and downloads public keys from `https://github.com/<username>.keys` to `~/.ssh/authorized_keys`. Backs up existing keys and sets proper permissions (700/600).

#### `run_once_before_30-setup-gopass-config.sh.tmpl`
**Optional:** Attempts to copy `chezmoi.toml` from gopass to `~/.config/chezmoi/chezmoi.toml`. If config already exists or gopass is unavailable, it skips gracefully. The config file contains template variables needed by other scripts.

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
