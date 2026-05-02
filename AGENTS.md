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
├── .chezmoidata/packages.yaml       # Package & custom-tool definitions per profile
├── .chezmoitemplates/
│   ├── helpers.sh                   # Output helpers, setup_brew_path, run, try
│   └── install_tool.sh              # Curl-based tool installer function
├── .chezmoiignore.tmpl              # OS-conditional ignores
├── dot_aliases.tmpl                 # Shell aliases (OS-conditional)
├── dot_gitconfig.tmpl               # Git config
├── dot_gitconfig-github.tmpl        # GitHub identity (alt template delimiters)
├── dot_gitconfig-gitlab.tmpl        # GitLab identity (alt template delimiters)
├── dot_tmux.conf                    # tmux config
├── dot_vimrc                        # Vim config (no .tmpl)
├── dot_zpreztorc.tmpl               # Prezto zsh framework config
├── dot_zshrc.tmpl                   # Main zsh config
├── dot_zsh/exact_completions/       # Zsh completions (exact_ removes unlisted files)
├── dot_config/                      # ~/.config/ files
│   ├── kitty/                       # Kitty terminal
│   ├── nvim/                        # Neovim (LazyVim)
│   ├── opencode/opencode.jsonc.tmpl # Opencode AI config (gopass API keys)
│   ├── starship.toml                # Starship prompt
│   └── yazi/                        # Yazi file manager
├── dot_config-work/opencode/        # Work-specific opencode config override
├── dot_local/
│   ├── bin/                         # Executable scripts
│   │   ├── executable_setup-chezmoi-remote.sh.tmpl
│   │   ├── executable_git-backup.sh.tmpl
│   │   └── executable_yazi-open.sh  # Static script (no .tmpl)
│   ├── share/opencode/              # Opencode personal auth
│   └── share-work/opencode/         # Opencode work auth
├── private_dot_env.tmpl             # ~/.env — API keys from gopass (600 perms)
├── private_dot_gnupg/               # ~/.gnupg/ — GPG agent config
├── private_dot_ssh/                 # ~/.ssh/ — authorized_keys from gopass
├── private_dot_vibe/                # ~/.vibe/ — Vibe CLI config; symlink_skills.tmpl points ~/.vibe/skills → ~/git/claude/skills
├── private_Library/                 # ~/Library/ — macOS app configs
├── run_once_before_10-setup-config-from-gopass.sh.tmpl
├── run_after_35-install-homebrew.sh.tmpl
├── run_after_40-install-packages.sh.tmpl
├── run_after_55-install-custom-tools.sh.tmpl
├── run_after_56-post-install-hooks.sh.tmpl  # MCP servers, Claude skills, fabric patterns (see below)
├── run_after_60-upgrades.sh.tmpl
└── run_once_after_90-finalize.sh.tmpl       # Prezto, tmux TPM+plugins, gopass push URLs, login shell
```

## File Naming Conventions

| Prefix | Result |
|--------|--------|
| `dot_` | `.filename` |
| `private_dot_` | `.filename` (600 perms) |
| `executable_` | executable file |
| `exact_` | removes target files not in source |
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

**Helpers** (from `helpers.sh`): `section`, `progress`, `finish`, `failed`, `success`, `warn`, `error`, `info`, `log`, `dim`

**Utility functions** (from `helpers.sh`):
- `setup_brew_path` — adds Homebrew to PATH (macOS `/opt/homebrew` or Linux `/home/linuxbrew`); call at start of any script needing `brew`
- `run "label" cmd [args...]` — runs command with progress label; exits on failure
- `try "label" cmd [args...]` — runs command with progress label; warns and continues on failure

**Naming**: `readonly UPPER_SNAKE_CASE` for constants, `lower_snake_case` for vars/functions.

## Go Templates

```bash
{{- $profile := .profile | default "basic" }}
{{ if eq .chezmoi.os "darwin" -}}macOS code{{- end }}
{{ if or (eq $profile "dev") (eq $profile "mac") -}}dev/mac code{{- end }}
```

- Profiles are additive but parallel: `basic` is always applied. `dev` (Linux) or `mac` (macOS) is merged on top. `dev` and `mac` are NOT hierarchical — they are separate platform profiles.
- Always default: `{{ .profile | default "basic" }}`
- Override template delimiters when `{{ }}` conflicts with target syntax:

```
{{- /* chezmoi:template:left-delimiter=[[  right-delimiter=]] */ -}}
[section]
  value = [[ .some_variable ]]
```

## YAML (packages.yaml)

```yaml
# Top-level custom installer registry (curl-based)
custom:
  toolname:
    check: "binary-name"      # Command to verify installation
    url: "https://..."        # Install script URL
    install_when: "missing"   # or "always" (re-run on every apply)
    requires: ["brew"]        # Command dependencies

# Package installation: always basic + ONE profile (dev OR mac, not both)
packages:
  basic:                      # Installed on ALL machines (Linux + macOS)
    custom: ["homebrew"]      # References keys from top-level custom: block
    taps: []
    apt: ["git", "curl"]      # Linux only
    brews: ["fzf", "neovim"]
    casks: []
    npm: []
  dev:                        # Linux additions (merged with basic)
    custom: ["opencode"]
    taps: []
    apt: ["btop"]
    brews: ["gh"]
    casks: []
    npm: []
  mac:                        # macOS additions (merged with basic, parallel to dev)
    custom: ["opencode"]
    taps: []
    brews: ["gopass"]
    casks: ["typora"]
    npm: []
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

## run_after_56: Post-Install Hooks

Runs on every `chezmoi apply` for `dev` and `mac` profiles. Four responsibilities in order:

1. **Yazi plugins** — `ya pkg install` inside `~/.config/yazi/` (only if yazi is in the profile)
2. **Claude MCP servers** — registers servers via `claude mcp add --scope user`, each gated on a `~/.env` var:
   - `context7` (HTTP) — requires `CONTEXT7_API_KEY`
   - `service-hub` (HTTP) — requires `SERVICEHUB_URL`
   - `firecrawl` (HTTP) — requires `FIRECRAWL_MCP`
3. **Claude skills** — clones/pulls `git@github.com:cloonix/claude.git` → `~/git/claude`, then copies `skills/` to `~/.claude/skills/`
4. **Fabric patterns** — clones/pulls personal patterns (`cloonix/fabric` → `~/git/fabric`) on every run; runs `fabric-ai -U` for upstream patterns only if >7 days since last update

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

**Work config override**: `dot_config-work/` and `dot_local/share-work/` hold work-specific configs. The `ocw()` shell function (in `dot_aliases.tmpl`) launches opencode with `OPENCODE_CONFIG_DIR` and `XDG_DATA_HOME` overridden to work paths, keeping personal and work sessions separated.

**Claude skills**: Managed in the separate `cloonix/claude` repo (`~/git/claude`). `run_after_56` keeps it up to date and deploys `skills/` to `~/.claude/skills/`. The `~/.vibe/skills` symlink (rendered from `private_dot_vibe/symlink_skills.tmpl`) points to the same `~/git/claude/skills` directory, so both tools share one skills source.
