# Project Instructions

Chezmoi dotfiles repo. Full reference in `AGENTS.md` — check it before making changes.

## Tech Stack
- Bash + Go templates, YAML (`packages.yaml`), managed by chezmoi
- Secret store: gopass (never commit secrets)
- Platforms: macOS (`mac` profile) + Linux/WSL2 (`dev` profile) + `basic` (all)

## Profiles
Three profiles — `basic` always applied, `dev` (Linux) or `mac` (macOS) merged on top.
`dev` and `mac` are **parallel**, not hierarchical. Always default: `{{ .profile | default "basic" }}`.

## File Naming (chezmoi)
| Prefix/Suffix | Target effect |
|---|---|
| `dot_` | `.filename` |
| `private_dot_` | `.filename` (600 perms) |
| `executable_` | executable bit |
| `exact_` | removes target files not in source |
| `run_after_NN` | runs on every `chezmoi apply` |
| `run_once_before/after_NN` | runs once (content-hash tracked) |
| `.tmpl` suffix | processed as Go template |

## Shell Script Style
```bash
#!/usr/bin/env bash
{{ template "helpers.sh" . }}
set -e
{{- $profile := .profile | default "basic" }}
```
- `run "label" cmd` — fatal step; `try "label" cmd` — non-fatal
- Constants: `readonly UPPER_SNAKE_CASE`, vars/functions: `lower_snake_case`

## Go Templates
- Secrets: `{{ gopass "path/to/secret" }}` — store in var to avoid repeated lookups
- Override delimiters when `{{ }}` conflicts with target syntax (see gitconfig templates)
- Profile checks: `{{ if eq .chezmoi.os "darwin" }}` or `{{ if or (eq $profile "dev") (eq $profile "mac") }}`

## Secrets
- Never commit secrets — all secrets via gopass or `private_dot_*` permissions
- `~/.env` rendered from `private_dot_env.tmpl` provides API keys at runtime

## Key Files
- `.chezmoidata/packages.yaml` — all package/tool definitions (single source of truth)
- `.chezmoitemplates/helpers.sh` — output helpers + `run`/`try`/`setup_brew_path`
- `dot_zshrc.tmpl` — main shell config
- `run_after_56-post-install-hooks.sh.tmpl` — MCP server registration, yazi plugins

## Common Commands
```bash
chezmoi diff                  # Preview changes
chezmoi apply                 # Apply config
chezmoi data | jq '.profile'  # Check active profile
bash -n <script>              # Syntax check
shellcheck <script>           # Lint
```

## Do Not Touch
- `README.md` — intentionally minimal ("No README.md needed")
- `.archive/` — unused configs kept for reference, do not delete

## Git Commits
Format: `type: description` (≤72 chars). Types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`
