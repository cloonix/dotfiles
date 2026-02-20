# Agent Instructions

This is a **chezmoi dotfiles repository** managing system configuration across multiple profiles (basic, dev, mac).

## Project Type & Tools

- **Type**: Shell scripts + Go templates (chezmoi)
- **Version Control**: Git
- **Languages**: Bash, YAML, Go templates
- **Platforms**: macOS, Linux

## Quick Reference Commands

### Chezmoi Operations
```bash
chezmoi diff          # Preview changes
chezmoi apply         # Apply configuration
chezmoi data          # View template variables
chezmoi data | jq '.profile'  # View current profile
chezmoi cd            # Navigate to source directory
chezmoi edit <file>   # Edit managed file
chezmoi add <file>    # Add new file to chezmoi
```

### Testing & Validation
```bash
# No automated test suite - validate manually:
chezmoi diff          # Preview all changes before applying
bash -n <script>      # Syntax check shell scripts
shellcheck <script>   # Lint shell scripts (if available)
yamllint <file>       # Lint YAML files (if available)
```

## Code Style Guidelines

### Shell Scripts

**General Principles:**
- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -e` (exit on error)
- Use readonly for constants
- Quote all variable references: `"$variable"`
- Check command existence: `command -v foo >/dev/null 2>&1`
- Redirect output when appropriate: `>/dev/null 2>&1`

**Naming Conventions:**
- Constants: `readonly UPPER_SNAKE_CASE`
- Variables: `lower_snake_case`
- Functions: `lower_snake_case()`

**Output & User Feedback:**
Use helper functions from `helpers.sh`:
```bash
section "Section Title"    # Bold section headers
progress "Action"          # Start progress indicator
finish                     # Complete progress (green "done")
failed                     # Failed progress (red "failed")
success "Message"          # Green checkmark
warn "Message"             # Yellow warning
error "Message"            # Red error
info "Message"             # Blue info
log "Message"              # Blue prefix
```

**Error Handling:**
- Always check command success
- Use `if command; then finish; else failed; exit 1; fi` pattern
- Exit with non-zero on failure: `exit 1`

**Example Pattern:**
```bash
#!/usr/bin/env bash
{{ template "helpers.sh" . }}

set -e

section "My Section"

if ! command -v foo >/dev/null 2>&1; then
    progress "Installing foo"
    if install_foo >/dev/null 2>&1; then
        finish
    else
        failed
        exit 1
    fi
else
    success "foo already installed"
fi
```

### Go Templates (chezmoi)

**Template Syntax:**
- Access chezmoi variables: `{{ .chezmoi.os }}`, `{{ .chezmoi.homeDir }}`
- Access custom data: `{{ .profile }}`, `{{ .name }}`, `{{ .email }}`
- Include templates: `{{ template "helpers.sh" . }}`
- Conditionals: `{{ if eq .chezmoi.os "darwin" }}...{{ end }}`
- Remove whitespace: Use `-` in delimiters: `{{- if ... -}}`

**Profile System:**
- Profiles are additive: basic ⊂ dev ⊂ mac
- Always default to "basic": `{{ .profile | default "basic" }}`
- Check profile: `{{ if eq $profile "dev" }}...{{ end }}`
- Multi-profile check: `{{ if or (eq $profile "dev") (eq $profile "mac") }}...{{ end }}`

**Common Patterns:**
```bash
{{- $profile := .profile | default "basic" }}
{{ if eq .chezmoi.os "darwin" -}}
  # macOS-specific code
{{- else if eq .chezmoi.os "linux" -}}
  # Linux-specific code
{{- end }}
```

### YAML Configuration

**Style:**
- 2-space indentation
- Use lowercase for keys
- Quote strings with special characters
- Use lists for arrays (not inline)
- Comment sections clearly

**Package Structure:**
```yaml
packages:
  basic:
    custom: ["installer1"]
    apt: ["package1", "package2"]
    brews: ["tool1", "tool2"]
    casks: []
  
  dev:
    # Additional packages on top of basic
    brews: ["devtool1"]
```

### File Naming (Chezmoi Conventions)

- `dot_filename` → `.filename`
- `private_dot_filename` → `.filename` (private, 600 permissions)
- `executable_filename` → `filename` (executable)
- `run_once_before_*.sh.tmpl` → Run once before apply
- `run_after_*.sh.tmpl` → Run every time after apply
- `filename.tmpl` → Template file (processed)

### Git Commit Messages

- Use conventional format: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `chore`
- Keep first line under 72 characters
- Be descriptive but concise
- Examples:
  - `feat: add fabric-ai to mac profile`
  - `fix: correct gopass config path`
  - `docs: update profile descriptions`
  - `chore: update homebrew packages`

## Project Structure

```
.
├── .chezmoidata/                # Data files (packages.yaml)
├── .chezmoitemplates/           # Shared templates (helpers.sh)
├── dot_*                        # Files → ~/.filename
├── private_*                    # Private files (600 perms)
├── run_once_before_*.sh.tmpl    # Setup scripts (run once)
├── run_after_*.sh.tmpl          # Post-apply scripts
├── dot_config/                  # Config files → ~/.config/
├── dot_local/bin/               # Executable scripts
│   └── setup-chezmoi-remote.sh  # Remote machine deployment
├── AGENTS.md                    # This file
├── PROFILES.md                  # Profile system documentation
└── README.md                    # Project readme
```

### Run Scripts Overview

**Execution order:**
1. `run_once_before_10-setup-config-from-gopass.sh.tmpl` - Fetch chezmoi config from gopass
2. `run_once_before_20-setup-ssh.sh.tmpl` - Configure SSH keys
3. `run_after_25-copy-gopass-files-local.sh.tmpl` - Copy files from gopass (interactive)
4. `run_after_50-install-packages.sh.tmpl` - Install packages (OS-specific: apt/brew/casks)
5. `run_after_60-upgrades.sh.tmpl` - Upgrade tools (Homebrew, OpenCode)
6. `run_once_after_90-finalize.sh.tmpl` - Setup frameworks (Prezto, gopass) and finalize

**Key scripts:**
- **install-packages**: Consolidated macOS/Linux package installation with profile support
- **upgrades**: Combined Homebrew and tool upgrades in single section
- **finalize**: Framework setup (Prezto, gopass config) + shell change + completion message
- **copy-gopass-files-local**: Interactive file copy from gopass (local only)
- **setup-chezmoi-remote**: Remote deployment script (in dot_local/bin/)

## Landing the Plane (Session Completion)

**When ending a work session**, MUST complete ALL steps. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **Run quality gates** (if code changed):
   ```bash
   chezmoi diff          # Verify changes look correct
   bash -n <script>      # Syntax check any modified scripts
   ```
2. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
3. **Clean up** - Clear stashes, prune remote branches
4. **Verify** - All changes committed AND pushed
5. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds

## Common Tasks

### Adding a New Package
1. Edit `.chezmoidata/packages.yaml`
2. Add to appropriate profile's brews/casks/apt list
3. Test: `chezmoi diff`, then `chezmoi apply`

### Creating a New Script
1. Use template naming: `run_after_NN-description.sh.tmpl`
2. Include helpers: `{{ template "helpers.sh" . }}`
3. Add `set -e` and proper error handling
4. Use progress indicators for user feedback

### Modifying Config Files
1. Find in dot_config/
2. Edit template variables ({{ ... }})
3. Test changes: `chezmoi diff`
4. Apply: `chezmoi apply`

### Working with Secrets
- Never commit secrets directly
- Use gopass references in templates: `{{ .secret_var }}`
- Mark files as private: `private_dot_filename`
