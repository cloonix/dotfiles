# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Features

- 🔒 **Privacy-first**: All sensitive data is templated and stored locally
- 🚀 **One-command setup**: Clone and apply in a single command
- 🔄 **Auto-updating**: Plugins and tools update on each apply
- 🎨 **Consistent theming**: Kanagawa colorscheme across all tools

## Quick Start

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply cloonix/dotfiles
```

On first run, you'll be prompted for your personal information (email, GPG key, etc). These values are stored locally and **never** committed to the repository.

## Manual Installation

```bash
# Install chezmoi
brew install chezmoi  # macOS
# or: apt install chezmoi  # Ubuntu/Debian

# Initialize from this repository
chezmoi init https://github.com/cloonix/dotfiles.git

# Review what will change
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

## What You'll Be Asked

On first run, chezmoi will prompt you for:

| Prompt | Example | Purpose |
|--------|---------|---------|
| Personal email | `user@example.com` | Default git email |
| GPG signing key ID | `C844D1532E58D88C` | Git commit signing |
| Full name | `John Doe` | Git commit author |
| GitHub noreply email | `123456+user@users.noreply.github.com` | GitHub commits |
| GitLab noreply email | `5229-user@users.noreply.gitlab.example.com` | GitLab commits |
| GitLab domain | `gitlab.example.com` | Your GitLab instance |

These values are stored in `~/.config/chezmoi/.chezmoi.toml` (not tracked by git).

## What's Included

### Editors
- **Neovim** (>= 0.11) with LazyVim, Mason, and LSP support
- **Vim** with vim-plug and Iceberg theme

### Shell & Terminal
- **Zsh** with Prezto framework (auto-updating)
- **tmux** with TPM and custom keybindings
- **yazi** file manager with plugins (bookmarks, git, compress, etc.)

### Development Tools
- **Git** config with domain-specific settings
- **k9s** Kubernetes TUI with multiple skins

### Automation
Run scripts automatically install and update:
- Neovim plugins (Lazy.nvim)
- Vim plugins (vim-plug)
- tmux plugins (TPM)
- Yazi packages (ya)
- Zsh/Prezto (git pull)

## Daily Workflow

### Making Changes

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# Preview changes
chezmoi diff

# Apply changes
chezmoi apply

# Add a new dotfile to chezmoi
chezmoi add ~/.config/newfile
```

### Syncing with Git

**Commit and push your changes:**

```bash
chezmoi cd              # Enter chezmoi source directory
git status              # Check what changed
git add .
git commit -m "Description of changes"
git push
exit                    # Return to previous directory
```

**Pull updates from repository:**

```bash
chezmoi update          # Pull latest and apply in one command
```

Or manually:
```bash
chezmoi git pull        # Pull latest changes
chezmoi apply           # Apply the changes
```

### Updating Configuration Values

If you need to change your email, GPG key, or other personal data:

```bash
chezmoi init            # Re-run initialization prompts
chezmoi apply
```

## File Structure

```
~/.local/share/chezmoi/           # Chezmoi source directory
├── .chezmoi.toml.tmpl            # Template for personal data (prompts on init)
├── .chezmoiignore                # Files to ignore
├── .chezmoitemplates/            # Shared templates
│   └── helpers.sh                # Shell helper functions
├── dot_config/                   # Config files (~/.config/)
│   ├── nvim/                     # Neovim configuration
│   ├── yazi/                     # Yazi configuration
│   └── k9s/                      # k9s skins and config
├── dot_gitconfig.tmpl            # Main git config (templated)
├── dot_gitconfig-github.tmpl     # GitHub-specific config
├── dot_gitconfig-gitlab.tmpl     # GitLab-specific config
├── dot_zshrc.tmpl                # Zsh configuration
├── dot_tmux.conf                 # tmux configuration
└── run_*.sh.tmpl                 # Automation scripts
```

## Security & Privacy

✅ **No sensitive data in repository**
- All personal information is templated
- `.chezmoi.toml` (with your actual data) is git-ignored
- No API keys, passwords, or private keys tracked

✅ **Safe to fork and share**
- Clone this repo and customize for your own use
- Your personal values will be prompted on first run

## Troubleshooting

**Config file template has changed:**
```bash
chezmoi init            # Regenerate config with prompts
chezmoi apply
```

**Plugins not installing:**
```bash
chezmoi apply -v        # Verbose output to see what's failing
```

**Reset everything:**
```bash
chezmoi purge           # Remove all managed files
chezmoi init --apply    # Start fresh
```

## Requirements

- Git
- curl
- zsh
- tmux
- vim (optional)
- nvim >= 0.11 (optional, for Neovim config)
- yazi (optional, for file manager)

Missing dependencies will be detected on first run with installation instructions.

## License

MIT
