# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Quick Start

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply cloonix/dotfiles
```

## Manual Installation

```bash
# Install chezmoi
brew install chezmoi  # macOS
# or: sudo apt install chezmoi  # Ubuntu/Debian

# Initialize from this repository
chezmoi init https://github.com/cloonix/dotfiles.git

# Review changes before applying
chezmoi diff

# Apply the dotfiles
chezmoi apply
```

## First Run

On first run, chezmoi will prompt you for:
- Personal email address
- GPG signing key ID
- Full name
- GitHub noreply email
- GitLab noreply email
- GitLab domain

These values are stored locally in `~/.config/chezmoi/.chezmoi.toml` and are **not** committed to this repository.

## What's Included

- **Editors**: Neovim (>= 0.11), Vim
- **Shell**: Zsh with Prezto
- **Terminal**: tmux, yazi
- **Tools**: Git config, k9s skins

## Daily Usage

```bash
# Edit a dotfile
chezmoi edit ~/.zshrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Add a new dotfile
chezmoi add ~/.config/newfile

# Update to latest from repository
chezmoi update
```

## Updating Your Dotfiles

### Update local changes to git:

```bash
# Navigate to chezmoi source directory
chezmoi cd

# Check status
git status

# Add and commit changes
git add .
git commit -m "Update dotfiles"

# Push to GitHub
git push

# Exit back to original directory
exit
```

### Pull updates from repository:

```bash
# Pull latest changes and apply
chezmoi update

# Or manually:
chezmoi git pull
chezmoi apply
```

## License

MIT
