# Chezmoi Profile System

## Profiles

| Profile | Description | Use For |
|---------|-------------|---------|
| **basic** | Minimal: git, curl, zsh, glow, fastfetch | Jump hosts, minimal servers |
| **dev** | Full dev environment + neovim, go, gopass, yazi, zellij | Linux workstations, WSL2 |
| **mac** | Dev profile + macOS GUI apps (casks) | MacBooks, Mac workstations |

Profiles are additive: `basic` ⊂ `dev` ⊂ `mac`

## Setup

Set profile in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    profile = "dev"  # basic, dev, or mac
```

## Quick Reference

```bash
chezmoi data | jq '.profile'      # View current profile
chezmoi diff                       # Preview changes
chezmoi apply                      # Apply configuration
```

See `.chezmoidata/packages.yaml` for exact package lists per profile.
