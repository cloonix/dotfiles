# Chezmoi Profile System

This dotfiles repository supports multiple profiles to adapt the setup for different use cases and environments.

## Available Profiles

### **basic** - Minimal Setup
Lightweight configuration for simple machines or servers with minimal requirements.

**Includes:**
- Essential tools: git, curl, zsh
- Basic shell configuration
- Glow for markdown viewing
- Fastfetch for system info
- No development tools
- No Neovim configuration

**Use for:**
- Jump hosts
- Minimal servers
- Quick temporary setups
- Systems where you don't need full dev environment

---

### **dev** - Full Development Environment
Complete development setup for Linux servers and workstations.

**Includes:**
- All basic tools
- Full development stack: go, neovim, ansible
- Development utilities: opencode, dstask, yazi, zellij
- Security tools: gopass, nmap
- File management: fd, fzf, ncdu
- System monitoring: btop
- Archive tools: sevenzip
- Syncthing for file synchronization
- Complete Neovim configuration
- Gopass configuration with push remotes

**Use for:**
- Linux development machines
- Remote development servers
- Docker containers for development
- WSL2 environments

---

### **mac** - macOS with GUI Apps
Full macOS setup with development tools and GUI applications.

**Includes:**
- All development tools from 'dev' profile
- GUI applications (casks): claude-code
- macOS-specific configurations
- Complete Neovim configuration
- Gopass configuration

**Use for:**
- MacBook laptops
- Mac workstations
- macOS as primary development environment

---

## Setup Instructions

### Initial Setup

1. **Store your profile in gopass** (or create manually):

   Edit your `chezmoi.toml` and add the profile line:

   ```toml
   [data]
       email = "your@email.com"
       name = "Your Name"
       # ... other variables ...
       
       # Add this line (choose: basic, dev, or mac)
       profile = "dev"
   ```

2. **Copy config to chezmoi directory**:

   ```bash
   # If stored in gopass:
   gopass show config/chezmoi.toml > ~/.config/chezmoi/chezmoi.toml
   
   # Or create manually:
   mkdir -p ~/.config/chezmoi
   nano ~/.config/chezmoi/chezmoi.toml
   ```

3. **Initialize and apply**:

   ```bash
   # First time
   chezmoi init https://github.com/yourusername/dotfiles.git
   
   # Preview changes
   chezmoi diff
   
   # Apply configuration
   chezmoi apply
   ```

---

## Switching Profiles

To switch from one profile to another:

1. **Edit your config file**:

   ```bash
   nano ~/.config/chezmoi/chezmoi.toml
   ```

2. **Change the profile value**:

   ```toml
   [data]
       profile = "mac"  # Change to: basic, dev, or mac
   ```

3. **Update your gopass store** (optional but recommended):

   ```bash
   gopass insert -m config/chezmoi.toml
   # Paste your updated config
   ```

4. **Apply changes**:

   ```bash
   # Preview what will change
   chezmoi apply --dry-run
   
   # Apply the new profile
   chezmoi apply
   ```

---

## What Gets Installed

### Package Comparison

| Package           | basic | dev | mac |
|-------------------|-------|-----|-----|
| **Core Tools**    |       |     |     |
| git               | ✓     | ✓   | ✓   |
| curl              | ✓     | ✓   | ✓   |
| zsh               | ✓     | ✓   | ✓   |
| glow              | ✓     | ✓   | ✓   |
| fastfetch         | ✓     | ✓   | ✓   |
| **Dev Tools**     |       |     |     |
| neovim            |       | ✓   | ✓   |
| go                |       | ✓   | ✓   |
| opencode          |       | ✓   | ✓   |
| ansible           |       | ✓   | ✓   |
| hugo              |       | ✓   | ✓   |
| **Utilities**     |       |     |     |
| yazi              |       | ✓   | ✓   |
| zellij            |       | ✓   | ✓   |
| fd                |       | ✓   | ✓   |
| fzf               |       | ✓   | ✓   |
| vivid             |       | ✓   | ✓   |
| **Security**      |       |     |     |
| gopass            |       | ✓   | ✓   |
| nmap              |       | ✓   | ✓   |
| **System Tools**  |       |     |     |
| btop              |       | ✓   | ✓   |
| ncdu              |       | ✓   | ✓   |
| dstask            |       | ✓   | ✓   |
| syncthing         |       | ✓   | ✓   |
| hcloud            |       | ✓   | ✓   |
| sevenzip          |       | ✓   | ✓   |
| logrotate         |       | ✓   | ✓   |
| **GUI Apps**      |       |     |     |
| claude-code       |       | ✓   | ✓   |
| **Linux-specific**|       |     |     |
| tmux              |       | ✓   |     |
| build-essential   |       | ✓   |     |
| keychain          |       | ✓   |     |

### Configuration Differences

| Feature                    | basic | dev | mac |
|----------------------------|-------|-----|-----|
| Neovim config              |       | ✓   | ✓   |
| Fastfetch on login         |       | ✓   | ✓   |
| Go bin in PATH             |       | ✓   | ✓   |
| Gopass configuration       |       | ✓   | ✓   |
| Prezto framework           | ✓     | ✓   | ✓   |
| Yazi config                |       | ✓   | ✓   |
| Zellij config              |       | ✓   | ✓   |
| K9s config                 |       | ✓   | ✓   |

---

## Verification Commands

Check your current profile and what would be installed:

```bash
# View current profile
chezmoi data | jq '.profile'

# Test profile variable
chezmoi execute-template '{{ .profile }}'

# Preview packages for current profile (macOS)
chezmoi execute-template '{{ range (index .packages .profile "darwin").brews }}{{ . }}{{ "\n" }}{{ end }}'

# Preview packages for current profile (Linux)
chezmoi execute-template '{{ range (index .packages .profile "linux").brews }}{{ . }}{{ "\n" }}{{ end }}'

# See what files would change
chezmoi status

# Preview all changes
chezmoi diff

# Dry run apply
chezmoi apply --dry-run
```

---

## Advanced: Multiple Machines

### Strategy 1: Different Config Files in Gopass

Store separate configs for each machine type:

```bash
# Store configs
gopass insert -m config/chezmoi-laptop.toml    # profile = "mac"
gopass insert -m config/chezmoi-server.toml    # profile = "basic"
gopass insert -m config/chezmoi-workstation.toml  # profile = "dev"

# On each machine, copy the appropriate one
gopass show config/chezmoi-laptop.toml > ~/.config/chezmoi/chezmoi.toml
```

### Strategy 2: Hostname-Based Automatic Selection

For automatic profile selection based on hostname, you could add this logic to templates:

```go-template
{{- $profile := .profile | default "dev" -}}
{{- if hasPrefix "jump-" .chezmoi.hostname -}}
{{-   $profile = "basic" -}}
{{- else if hasPrefix "mac-" .chezmoi.hostname -}}
{{-   $profile = "mac" -}}
{{- end -}}
```

---

## Troubleshooting

### Profile not taking effect

1. Check profile is set in config:
   ```bash
   chezmoi data | jq '.profile'
   ```

2. Verify config file exists:
   ```bash
   cat ~/.config/chezmoi/chezmoi.toml | grep profile
   ```

3. Re-run apply:
   ```bash
   chezmoi apply -v
   ```

### Packages not installing

1. Check the install script is running:
   ```bash
   # See which scripts would run
   chezmoi status
   ```

2. Force re-run of package installation:
   ```bash
   # Change the hash to force re-run
   touch .chezmoidata/packages.yaml
   chezmoi apply
   ```

### Wrong packages installed

1. Verify profile in templates:
   ```bash
   chezmoi execute-template '{{ .profile }}'
   ```

2. Check packages.yaml structure:
   ```bash
   cat .chezmoidata/packages.yaml
   ```

---

## Profile Design Principles

1. **basic**: Absolute minimum - just shell and git
2. **dev**: Full development environment without GUI requirements
3. **mac**: Everything including GUI apps specific to macOS

The profiles are additive - each builds on the previous concept:
- `basic` ⊂ `dev` ⊂ `mac` (in terms of functionality)

Choose the smallest profile that meets your needs to keep systems lean.
