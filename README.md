# Dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

No README.md needed. @Claude, don't touch this 😂

## Scripts

chezmoi runs scripts in filename order. `before` scripts run before files are applied, `after` scripts run after. `run_once_*` scripts only run once (tracked by content hash); `run_after_*` scripts run on every `chezmoi apply`.

### Before apply (run once)

| Script | What it does |
|--------|-------------|
| `run_once_before_10-setup-config-from-gopass.sh.tmpl` | Prompts for a profile (basic / dev / mac), fetches the matching `chezmoi.toml` from gopass and writes it to `~/.config/chezmoi/chezmoi.toml`. Exits early so the user re-runs `chezmoi apply` with the new config in place. Skipped if the config file already exists. |
| `run_once_before_20-setup-ssh.sh.tmpl` | ~~Fetched SSH keys from GitHub~~ — replaced by the declarative `~/.ssh/authorized_keys` template. |

### After apply (every apply)

| Script | What it does |
|--------|-------------|
| `run_after_35-install-homebrew.sh.tmpl` | Installs Homebrew if missing (uses `NONINTERACTIVE=1` on Linux). Updates Homebrew if already installed. Only runs when `homebrew` is listed in the profile's custom tools. |
| `run_after_40-install-packages.sh.tmpl` | Installs all packages for the active profile. On Linux: APT packages first, then Linuxbrew formulae. On macOS: brew taps, formulae, casks, then npm globals. Merges basic + profile package lists. |
| `run_after_55-install-custom-tools.sh.tmpl` | Installs curl-based tools defined in `packages.yaml` under `custom:`. Tools with `install_when: missing` only install if the binary is absent. Tools with `install_when: always` upgrade on every run. Dependency checks (`requires:`) are honoured. |
| `run_after_56-post-install-hooks.sh.tmpl` | Post-install configuration that needs to run after packages are present. Currently: clones/updates the fabric patterns repo and runs `fabric-ai -U` — but only if the patterns are older than 7 days. |
| `run_after_60-upgrades.sh.tmpl` | Runs `brew upgrade`, `brew autoremove`, and `brew cleanup -s`. Only active when `brew` is available. Failures are non-fatal (uses `try`). |

### After apply (run once)

| Script | What it does |
|--------|-------------|
| `run_once_after_90-finalize.sh.tmpl` | One-time finalisation: installs or updates Prezto (zsh framework), configures gopass push URLs (dev/mac profiles), changes the login shell to zsh, and prints a summary with next steps. |

### Helper templates

| Template | What it does |
|----------|-------------|
| `.chezmoitemplates/helpers.sh` | Shell helpers injected into every script via `{{ template "helpers.sh" . }}`. Provides coloured output functions (`section`, `progress`, `finish`, `failed`, `success`, `warn`, `info`, `log`), `setup_brew_path` (adds Homebrew to PATH for both macOS and Linux), `run` (runs a command — exits on failure), and `try` (runs a command — warns and continues on failure). |
| `.chezmoitemplates/install_tool.sh` | `install_tool` function used by script 55. Downloads and runs a remote install script via curl, with rate-limit detection and graceful degradation. |