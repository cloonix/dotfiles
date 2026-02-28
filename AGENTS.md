# Agent Instructions

**chezmoi dotfiles repository** managing system configuration across profiles (basic, dev, mac).

- **Stack**: Bash, Go templates, YAML
- **Platforms**: macOS, Linux

## Quick Reference

```bash
chezmoi diff          # Preview changes
chezmoi apply         # Apply configuration
chezmoi data          # View template variables
chezmoi data | jq '.profile'
bash -n <script>      # Syntax check
shellcheck <script>   # Lint (if available)
```

## Project Structure

```
.
├── .chezmoidata/packages.yaml       # Package definitions per profile
├── .chezmoitemplates/               # Shared templates (helpers.sh)
├── dot_*/private_*/executable_*     # Managed files
├── dot_config/                      # ~/.config/ files
├── dot_config-work/                 # Work-specific config overrides
├── dot_local/bin/                   # Executable scripts
│   ├── executable_setup-chezmoi-remote.sh.tmpl
│   └── executable_git-backup.sh.tmpl
├── run_once_before_10-setup-config-from-gopass.sh.tmpl
├── run_once_before_20-setup-ssh.sh.tmpl
├── run_after_35-install-homebrew.sh.tmpl
├── run_after_40-install-packages.sh.tmpl
├── run_after_55-install-custom-tools.sh.tmpl
├── run_after_56-post-install-hooks.sh.tmpl
├── run_after_60-upgrades.sh.tmpl
└── run_once_after_90-finalize.sh.tmpl
```

## File Naming Conventions

| Prefix | Result |
|--------|--------|
| `dot_` | `.filename` |
| `private_dot_` | `.filename` (600 perms) |
| `executable_` | executable file |
| `run_once_before_` | run before apply, once |
| `run_after_` | run after every apply |
| `.tmpl` suffix | processed as Go template |

## Shell Script Style

```bash
#!/usr/bin/env bash
{{ template "helpers.sh" . }}

set -e

section "My Section"

if ! command -v foo >/dev/null 2>&1; then
    progress "Installing foo"
    if install_foo >/dev/null 2>&1; then finish; else failed; exit 1; fi
else
    success "foo already installed"
fi
```

**Helpers** (from `helpers.sh`): `section`, `progress`, `finish`, `failed`, `success`, `warn`, `error`, `info`, `log`

**Naming**: `readonly UPPER_SNAKE_CASE` for constants, `lower_snake_case` for vars/functions.

## Go Templates

```bash
{{- $profile := .profile | default "basic" }}
{{ if eq .chezmoi.os "darwin" -}}macOS code{{- end }}
{{ if or (eq $profile "dev") (eq $profile "mac") -}}dev/mac code{{- end }}
```

- Profiles are additive: basic ⊂ dev ⊂ mac
- Always default: `{{ .profile | default "basic" }}`

## YAML (packages.yaml)

```yaml
packages:
  basic:
    custom: ["tool1"]
    apt: ["pkg1"]
    brews: ["brew1"]
    casks: []
  dev:
    brews: ["devtool1"]   # additive on top of basic
```

## Secrets

- Never commit secrets
- `{{ gopass "path/to/secret" }}` — plain password
- `{{ output "gopass" "--password" "path" "field" | trim }}` — named field
- Store in variable to avoid repeated lookups: `{{- $key := gopass "path" -}}`
- Use `private_dot_filename` for 600 permissions

## Git Commits

Format: `type: description` (under 72 chars)
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`

## setup-chezmoi-remote Script

`~/.local/bin/setup-chezmoi-remote` bootstraps chezmoi on a remote host over SSH without requiring gopass there.

**Core idea — render locally, apply remotely:**
Templates are rendered on the local machine (where gopass is available) using `chezmoi archive`. The resulting tarball (with secrets already baked in) is streamed to the remote and extracted before chezmoi runs. When chezmoi then applies on the remote, it sees no diff for those files and skips re-rendering them (no gopass needed remotely). Run scripts (`run_after_*`) still execute normally on the remote.

**Usage:**
```bash
setup-chezmoi-remote [OPTIONS] <ssh-target>

# Options:
#   -c, --config NAME      gopass config profile: basic|dev|mac (default: basic)
#   -r, --repo   REPO      chezmoi GitHub repo to clone (default: cloonix)
#   -b, --branch BRANCH    git branch (optional)
#   -u, --remote-user USER remote username (auto-detected via SSH if omitted)
#   -a, --arch   ARCH      remote CPU arch: amd64|arm64 (default: amd64)

setup-chezmoi-remote dev
setup-chezmoi-remote -c dev user@192.168.1.100
setup-chezmoi-remote -c dev -b feature-branch -r cloonix root@example.com
setup-chezmoi-remote -c dev -u claus -a arm64 my-server
```

**Step-by-step execution:**

1. **Detect remote environment** — SSH `whoami` + `echo $HOME` to get the remote user and home directory.
2. **Fetch config from gopass** — `gopass fscopy config/chezmoi/<profile>.toml` to a local temp file (cleaned up on exit).
3. **Render & copy dotfiles** — `chezmoi archive` is called locally with:
   - `--config` pointing to the temp TOML
   - `--destination` set to the remote `$HOME` so paths are correct
   - `--override-data` injecting `chezmoi.os=linux` and the target `arch`/`homeDir`
   - the resulting tar is piped directly into `tar -x` on the remote via SSH
4. **Remote bootstrap** — a heredoc runs on the remote via `ssh bash -l -c`:
   - installs `curl` and `git` via the available package manager (apt / yum / brew)
   - writes the chezmoi config to `~/.config/chezmoi/chezmoi.toml` (piped from local)
   - sets `NONINTERACTIVE=1` and `CI=1` for non-interactive scripts
   - pulls latest changes if the chezmoi source dir already exists
   - runs `chezmoi init --force` to install chezmoi and clone the repo
   - runs `chezmoi apply --force --exclude files` — skips file rendering (already done), runs all run scripts (packages, upgrades, finalize)

**Secret handling summary:**

| Stage | Where | gopass |
|-------|-------|--------|
| `chezmoi archive` | local machine | yes |
| tar extraction | remote | not needed |
| `chezmoi apply --exclude files` | remote | not needed |

## Common Tasks

**Add package**: Edit `.chezmoidata/packages.yaml` → `chezmoi diff` → `chezmoi apply`

**New script**: Name as `run_after_NN-name.sh.tmpl`, include `{{ template "helpers.sh" . }}`, add `set -e`

**Modify config**: Edit in `dot_config/`, verify with `chezmoi diff`, apply with `chezmoi apply`
