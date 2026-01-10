# Chezmoi Profile System

## Profiles

| Profile | Description | Use For |
|---------|-------------|---------|
| **basic** | Minimal: git, curl, zsh, neovim, starship, zellij | Jump hosts, minimal servers |
| **dev** | Full Linux dev environment | Linux workstations, WSL2 |
| **mac** | Full macOS dev environment + GUI apps (casks) | MacBooks, Mac workstations |

## Profile Architecture

Profiles are **parallel combinations**, not hierarchical:
- **basic + dev** = Linux/WSL2 development environment
- **basic + mac** = macOS development environment

The `basic` profile provides minimal essentials (git, zsh, neovim, etc.) shared by all machines.
The `dev` and `mac` profiles add platform-specific development tools.

**Note:** Packages shared between dev and mac (e.g., `go`, `lazygit`, `yazi`) are intentionally duplicated since they serve different operating systems.

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
