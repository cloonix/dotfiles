# .zshrc Template - Improvement Analysis

**Date:** January 19, 2026  
**Analyzed File:** `dot_zshrc.tmpl`  
**Related Files:** `dot_aliases.tmpl`, `dot_zpreztorc`

---

## Executive Summary

Your `.zshrc` configuration is well-structured and makes good use of chezmoi templating. This analysis identifies **12 improvement areas** across performance, functionality, and user experience. Most improvements are low-risk enhancements that build on your existing setup.

### Current Strengths
- ✅ Clear organizational structure with labeled sections
- ✅ Proper use of chezmoi templates for multi-profile support
- ✅ PATH deduplication checks prevent duplicates
- ✅ Conditional command availability checks
- ✅ Clean separation (aliases in dedicated file)
- ✅ Good agent management (SSH, GPG)

---

## Improvement Categories

### 🎯 High Impact / Low Effort
1. FZF Integration
2. Performance Optimizations
3. Completion Enhancements

### 🔧 Medium Impact / Medium Effort
4. History Configuration
5. Smart Directory Navigation
6. Environment Variable Organization

### 💡 Nice to Have
7. Additional Tool Integration
8. Error Handling & Diagnostics
9. Security Hardening

### 🔍 Requires Decision
10. Prezto Module Optimization
11. Profile-Specific Enhancements
12. Shell Options & Behavior

---

## Detailed Improvement Analysis

### 1. Performance Optimizations ⚡ (#done)

**Current Issues:**
- `fastfetch` runs on every shell startup (including subshells)
- Duplicate `compinit` call (Prezto completion module already runs this)
- GPG agent connect runs on every shell open
- No completion caching configured

**Impact:** Shell startup time 100-300ms slower than necessary

**Proposed Changes:**

```bash
# Run fastfetch only on login shells, not subshells
if [[ -o login ]] && command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi

# Remove duplicate compinit (lines 73-75)
# Prezto's completion module handles this

# Cache completion dumps for 24h
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C  # Skip security checks for cached file
fi

# Lazy-load GPG agent only when GPG is actually used
if command -v gpg-connect-agent >/dev/null 2>&1; then
  export GPG_TTY=$(tty)
  # Remove automatic connection, let GPG start agent on first use
fi
```

**Expected Improvement:** 150-250ms faster shell startup

---

### 2. FZF Integration 🔍 (#done)

**Current State:**
- FZF installed in dev/mac profiles
- No keybindings or shell integration configured
- Missing fuzzy search capabilities

**Proposed Changes:**

```bash
{{- if or (eq $profile "dev") (eq $profile "mac") }}
# FZF configuration
if command -v fzf >/dev/null 2>&1; then
  # Enable FZF keybindings and completions
  if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
  elif [[ -d /opt/homebrew/opt/fzf ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.zsh
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
  elif [[ -d /home/linuxbrew/.linuxbrew/opt/fzf ]]; then
    source /home/linuxbrew/.linuxbrew/opt/fzf/shell/completion.zsh
    source /home/linuxbrew/.linuxbrew/opt/fzf/shell/key-bindings.zsh
  fi

  # FZF customization
  export FZF_DEFAULT_OPTS="
    --height 40%
    --layout=reverse
    --border
    --inline-info
    --color=dark
    --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
    --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
  "
  
  # Use fd for better file search if available
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  fi
  
  # Preview files with bat if available
  if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
  fi
fi
{{- end }}
```

**New Capabilities:**
- **Ctrl+R**: Fuzzy history search with preview
- **Ctrl+T**: Fuzzy file search with preview
- **Alt+C**: Fuzzy directory search and cd
- **Tab completion**: Enhanced fuzzy completion for commands

---

### 3. History Configuration 📜 (#done)

**Current State:**
- No explicit history settings in `.zshrc`
- Relying entirely on Prezto defaults
- History size may be limited (Prezto default: 10,000)

**Proposed Changes:**

```bash
# History configuration (explicit settings)
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000                  # Lines of history in memory
SAVEHIST=50000                  # Lines of history to save to file

# History options
setopt EXTENDED_HISTORY          # Record timestamp of command
setopt HIST_EXPIRE_DUPS_FIRST    # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS          # Ignore duplicated commands history list
setopt HIST_IGNORE_SPACE         # Ignore commands that start with space
setopt HIST_VERIFY               # Show command with history expansion before running
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks from history
setopt INC_APPEND_HISTORY        # Write to history file immediately, not on exit
# setopt SHARE_HISTORY           # Share history between all sessions (optional)
```

**Benefits:**
- 5x more history retained (50k vs 10k)
- Timestamps for when commands were run
- Cleaner history (no duplicates, no extra whitespace)
- Better privacy (space-prefixed commands not saved)

**Note:** `SHARE_HISTORY` is commented - enable if you want real-time history sharing across all terminals.

---

### 4. Completion Enhancements 🎯 (#done)

**Current Issues:**
- Completion setup runs AFTER Prezto (should be before)
- No custom completion options configured
- Case-sensitive completions by default
- No menu selection for multiple matches

**Proposed Changes:**

```bash
# Completion configuration (move before Prezto loading)
fpath+=~/.zsh/completions

# Modern completion system
autoload -Uz compinit
compinit

# Completion options
zstyle ':completion:*' menu select                          # Menu selection
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # Case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"    # Colored listings
zstyle ':completion:*' group-name ''                        # Group matches
zstyle ':completion:*:descriptions' format '%B%d%b'         # Format group names
zstyle ':completion:*:warnings' format 'No matches found'   # No match message

# Partial completion (cd /u/lo/b -> /usr/local/bin)
zstyle ':completion:*' list-suffixes
zstyle ':completion:*' expand prefix suffix

# Cache completions for better performance
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${ZDOTDIR:-$HOME}/.zcompcache"

# Completion for common commands
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*' force-list always
zstyle ':completion:*:*:docker:*' option-stacking yes
zstyle ':completion:*:*:docker-*:*' option-stacking yes
```

**Location:** Move this section to BEFORE Prezto loading (around line 50)

---

### 5. Smart Directory Navigation 🗂️ (#done)

**Current State:**
- Manual `cd` required for directory changes
- No directory stack management
- No smart jumping to frequently used directories

**Proposed Changes:**

**Option A: Built-in Zsh Features**
```bash
# Directory navigation
setopt AUTO_CD              # Type directory name to cd
setopt AUTO_PUSHD           # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print directory stack
setopt PUSHD_TO_HOME        # Push to home from nowhere

# Directory stack aliases (add to dot_aliases.tmpl)
alias d='dirs -v'           # List directory stack
alias 1='cd -1'             # Jump to dir 1 in stack
alias 2='cd -2'             # Jump to dir 2 in stack
alias 3='cd -3'             # Jump to dir 3 in stack
```

**Option B: Add zoxide for Smart Jumping**

Add to `.chezmoidata/packages.yaml`:
```yaml
dev:
  brews:
    - "zoxide"  # Smart cd based on frecency

mac:
  brews:
    - "zoxide"
```

Add to `dot_zshrc.tmpl`:
```bash
{{- if or (eq $profile "dev") (eq $profile "mac") }}
# Smart directory jumping with zoxide
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  # Aliases: z, zi (interactive with fzf)
fi
{{- end }}
```

**Usage Examples:**
- `z dotfiles` - jump to chezmoi directory
- `z i` - interactive directory picker with fzf
- `zi` - interactive search with preview

**Recommendation:** Use zoxide - it learns your most-used directories and makes navigation much faster.

---

### 6. Environment Variable Organization 🌍 (#done)

**Current State:**
- Environment variables scattered across the file
- PATH modifications in multiple locations
- Mixed ordering

**Proposed Reorganization:**

```bash
# ========================================
# Environment Variables
# ========================================

# Terminal
export TERM=xterm-256color
export GPG_TTY=$(tty)

# Editor
if command -v nvim >/dev/null 2>&1; then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vim
  export VISUAL=vim
fi

# XDG Base Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# ========================================
# PATH Configuration
# ========================================

# Local bin
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# OpenCode (prepend to PATH)
if [[ -d "{{ .chezmoi.homeDir }}/.opencode/bin" ]] && [[ ":$PATH:" != *":{{ .chezmoi.homeDir }}/.opencode/bin:"* ]]; then
  export PATH="{{ .chezmoi.homeDir }}/.opencode/bin:$PATH"
fi

{{- if or (eq $profile "dev") (eq $profile "mac") }}
# Go bin (dev/mac profiles)
if [[ -d "$HOME/go/bin" ]] && [[ ":$PATH:" != *":$HOME/go/bin:"* ]]; then
  export PATH="$HOME/go/bin:$PATH"
fi
{{- end }}

# ========================================
# Secure Environment Variables
# ========================================

# Load from gopass-managed .env file
if [[ -f "$HOME/.env" ]]; then
  # Verify file has secure permissions
  if [[ "$(stat -f %A "$HOME/.env" 2>/dev/null || stat -c %a "$HOME/.env" 2>/dev/null)" == "600" ]]; then
    source "$HOME/.env"
  else
    echo "Warning: $HOME/.env has insecure permissions (should be 600)"
  fi
fi

# Load machine-specific overrides
if [[ -f "$HOME/.env.local" ]]; then
  source "$HOME/.env.local"
fi
```

**Benefits:**
- Clearer organization by category
- Security check for `.env` permissions
- Support for machine-specific `.env.local`
- XDG compliance
- Consistent PATH ordering (critical paths first)

---

### 7. Additional Tool Integration 🔌

**Recommended Tools to Consider:**

#### A. zoxide (Smart Directory Jumping)
**Status:** Strongly recommended  
**Package:** Already available in Homebrew  
**Integration:** Simple one-line init  
**Benefit:** Jump to frequently used directories instantly

```bash
# Add to packages.yaml
dev:
  brews:
    - "zoxide"
mac:
  brews:
    - "zoxide"

# Add to .zshrc
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
```

#### B. bat (Better cat)
**Status:** Recommended for dev/mac profiles  
**Package:** Available in Homebrew  
**Benefit:** Syntax highlighting, git integration, automatic paging

```bash
# Add to packages.yaml
dev:
  brews:
    - "bat"
mac:
  brews:
    - "bat"

# Add to .aliases
if command -v bat >/dev/null 2>&1; then
  alias cat="bat"
  alias catp="bat --style=plain"  # Plain cat without decorations
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"  # Use bat for man pages
fi
```

#### C. atuin (Better Shell History)
**Status:** Optional (advanced)  
**Package:** Available in Homebrew  
**Benefit:** Sync history across machines, better search, statistics

```bash
# Add to packages.yaml (if desired)
dev:
  brews:
    - "atuin"
mac:
  brews:
    - "atuin"

# Add to .zshrc
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
```

#### D. ripgrep (Better grep)
**Status:** Consider if not already installed  
**Note:** May already be available via other tools

---

### 8. Error Handling & Diagnostics 🐛

**Current State:**
- Silent failures when tools are missing
- No startup diagnostics
- Difficult to troubleshoot issues

**Proposed Changes:**

```bash
# Debug mode (set ZSH_DEBUG=1 before starting shell)
if [[ -n "$ZSH_DEBUG" ]]; then
  setopt XTRACE
  PS4='+%N:%i> '
fi

# Startup diagnostics function
check_shell_tools() {
  local missing_tools=()
  local expected_tools=(git nvim starship zellij)
  
  for tool in "${expected_tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
      missing_tools+=("$tool")
    fi
  done
  
  if [[ ${#missing_tools[@]} -gt 0 ]]; then
    echo "⚠ Missing expected tools: ${missing_tools[*]}"
    echo "  Run 'chezmoi apply' to install missing packages"
  fi
}

# Run diagnostics if ZSH_CHECK_TOOLS is set
if [[ -n "$ZSH_CHECK_TOOLS" ]]; then
  check_shell_tools
fi

# Fallback prompt if Starship not available
if ! command -v starship >/dev/null 2>&1; then
  # Set a basic prompt as fallback
  PROMPT='%F{blue}%~%f %# '
fi
```

**Usage:**
- `ZSH_DEBUG=1 zsh` - Start shell with trace output
- `ZSH_CHECK_TOOLS=1 zsh` - Check for missing tools on startup

---

### 9. Security Hardening 🔐 (#done)

**Current Issues:**
- `.env` file loaded without permission checks
- No validation of file ownership
- Secrets could be world-readable

**Proposed Changes:**

```bash
# Secure .env loading with validation
load_env_file() {
  local env_file="$1"
  
  if [[ ! -f "$env_file" ]]; then
    return 0
  fi
  
  # Check file permissions (should be 600 or 400)
  local perms
  if [[ "$OSTYPE" == darwin* ]]; then
    perms=$(stat -f %A "$env_file" 2>/dev/null)
  else
    perms=$(stat -c %a "$env_file" 2>/dev/null)
  fi
  
  if [[ "$perms" != "600" && "$perms" != "400" ]]; then
    echo "⚠ Warning: $env_file has insecure permissions ($perms)"
    echo "  Run: chmod 600 $env_file"
    return 1
  fi
  
  # Check file ownership
  if [[ ! -O "$env_file" ]]; then
    echo "⚠ Warning: $env_file is not owned by you"
    return 1
  fi
  
  source "$env_file"
}

# Load environment files
load_env_file "$HOME/.env"
load_env_file "$HOME/.env.local"
```

**Additional Security Measures:**

```bash
# Disable automatic telemetry for privacy
export HOMEBREW_NO_ANALYTICS=1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export NEXT_TELEMETRY_DISABLED=1

# Set secure umask
umask 022
```

---

### 10. Prezto Module Optimization 🔧

**Current Modules Loaded:**
```
environment, terminal, editor, history, directory, spectrum, 
utility, completion, homebrew, osx, git, python, tmux, 
syntax-highlighting, history-substring-search
```

**Questions for Optimization:**

#### A. Tmux Module
**Current:** Loaded in `.zpreztorc`  
**Issue:** You use `zellij` as your multiplexer, not tmux  
**Question:** Should tmux module be removed or is tmux still used occasionally?

**Recommendation:** Remove tmux module, add zellij aliases to `.aliases` (already done)

#### B. OSX Module
**Current:** Loaded unconditionally  
**Issue:** Only useful on macOS, loaded on Linux too  
**Question:** Should this be conditionally loaded?

**Proposed Change:**
```bash
# Make .zpreztorc a template: dot_zpreztorc.tmpl
{{- if eq .chezmoi.os "darwin" }}
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'homebrew' \
  'osx' \
  'git' \
  'python' \
  'syntax-highlighting' \
  'history-substring-search'
{{- else }}
zstyle ':prezto:load' pmodule \
  'environment' \
  'terminal' \
  'editor' \
  'history' \
  'directory' \
  'spectrum' \
  'utility' \
  'completion' \
  'homebrew' \
  'git' \
  'python' \
  'syntax-highlighting' \
  'history-substring-search'
{{- end }}
```

#### C. Python Module
**Current:** Auto-switch virtualenv enabled  
**Issue:** Can slow down directory changes  
**Question:** Do you frequently use Python virtualenvs?

**Options:**
- Keep if you actively develop Python
- Disable auto-switch if you don't need it
- Use manual virtualenv activation instead

#### D. Homebrew Module
**Current:** Loaded on both macOS and Linux  
**Status:** Correct - Linuxbrew also needs this

---

### 11. Profile-Specific Enhancements 🎨

**Current Profile System:**
- basic: Minimal (Linux + macOS)
- dev: Linux development
- mac: macOS development

**Proposed Enhancements:**

#### A. Add Profile Indicator to Prompt
```bash
# Add to .zshrc before Starship init
export STARSHIP_PROFILE="{{ $profile }}"
```

Then customize `starship.toml` to show profile in prompt.

#### B. Profile-Specific Tool Initialization

```bash
{{- if eq $profile "mac" }}
# macOS-specific integrations
if [[ -d "/Applications/Xcode.app" ]]; then
  # Xcode command line tools
  export PATH="/Applications/Xcode.app/Contents/Developer/usr/bin:$PATH"
fi
{{- end }}

{{- if eq $profile "dev" }}
# Linux dev-specific settings
# Docker completion if installed
if [[ -f /usr/share/bash-completion/completions/docker ]]; then
  source /usr/share/bash-completion/completions/docker
fi
{{- end }}
```

#### C. Hostname-Based Overrides

```bash
# Machine-specific configuration
if [[ -f "$HOME/.zshrc.local" ]]; then
  source "$HOME/.zshrc.local"
fi
```

**Use case:** Different settings for work laptop vs personal laptop, both with "mac" profile.

---

### 12. Shell Options & Behavior ⚙️

**Current State:**
- Relying on Prezto defaults
- No explicit shell options set in `.zshrc`

**Proposed Additions:**

```bash
# ========================================
# Shell Options
# ========================================

# Changing Directories
setopt AUTO_CD              # Type directory name to cd
setopt AUTO_PUSHD           # Make cd push old directory onto stack
setopt PUSHD_IGNORE_DUPS    # Don't push duplicates
setopt PUSHD_SILENT         # Don't print stack after pushd/popd
setopt PUSHD_TO_HOME        # pushd with no args goes to home

# Completion
setopt ALWAYS_TO_END        # Move cursor to end after completion
setopt AUTO_MENU            # Show completion menu on tab
setopt COMPLETE_IN_WORD     # Complete from both ends of word
setopt LIST_PACKED          # Smaller completion lists

# Expansion & Globbing  
setopt EXTENDED_GLOB        # Use extended globbing (#, ~, ^)
setopt GLOB_DOTS            # Include dotfiles in globs
setopt NO_CASE_GLOB         # Case-insensitive globbing

# Input/Output
setopt CORRECT              # Command correction
setopt INTERACTIVE_COMMENTS # Allow comments in interactive shell
setopt NO_BEEP              # Disable terminal bell
setopt RC_QUOTES            # Allow '' to escape ' in single quotes

# Job Control
setopt AUTO_RESUME          # Resume jobs with command name
setopt LONG_LIST_JOBS       # List jobs in long format
setopt NOTIFY               # Report job status immediately
```

**Note:** Some of these may overlap with Prezto modules - test to ensure no conflicts.

---

## Implementation Priority

### Phase 1: Quick Wins (30 minutes)
1. ✅ Add FZF integration
2. ✅ Improve history configuration
3. ✅ Remove duplicate compinit
4. ✅ Optimize fastfetch to login shells only

### Phase 2: Enhanced Functionality (1 hour)
5. ✅ Add completion enhancements
6. ✅ Reorganize environment variables
7. ✅ Add smart directory navigation
8. ✅ Add security checks for .env

### Phase 3: Optional Enhancements (1-2 hours)
9. ⚡ Add zoxide (if approved)
10. ⚡ Add bat integration (if approved)
11. ⚡ Convert .zpreztorc to template for conditional modules
12. ⚡ Add error handling & diagnostics

---

## Testing Plan

Before applying changes:

```bash
# 1. Backup current configuration
cp ~/.zshrc ~/.zshrc.backup
cp ~/.zpreztorc ~/.zpreztorc.backup

# 2. Preview changes
chezmoi diff

# 3. Apply changes
chezmoi apply

# 4. Test new shell
zsh

# 5. Benchmark startup time
for i in {1..10}; do time zsh -i -c exit; done

# 6. Verify completions work
# Try: git <TAB>, cd /u/l/b<TAB>

# 7. Test FZF keybindings
# Ctrl+R, Ctrl+T, Alt+C

# 8. Rollback if needed
chezmoi diff  # review
git checkout dot_zshrc.tmpl  # revert
chezmoi apply
```

---

## Questions & Decisions Needed

### Required Decisions:
1. **FZF**: Enable full integration? (Recommended: Yes)
2. **History Sharing**: Share history across sessions in real-time? (Recommended: No, use INC_APPEND)
3. **zoxide**: Add for smart directory jumping? (Recommended: Yes)
4. **bat**: Add for enhanced file viewing? (Recommended: Yes for dev/mac)
5. **Prezto tmux module**: Remove since you use zellij? (Recommended: Yes)
6. **Python virtualenv**: Keep auto-switching? (Depends on usage)

### Optional Enhancements:
7. **atuin**: Sync history across machines? (Optional, advanced)
8. **Starship config**: Add profile indicator? (Nice to have)
9. **Debug mode**: Add troubleshooting tools? (Low priority)
10. **.zpreztorc template**: Make OS-conditional? (Nice to have)

---

## Estimated Impact

### Performance
- **Startup Time:** -150-250ms (20-30% faster)
- **Completion Speed:** Noticeable improvement with caching
- **Memory:** Minimal impact (+2-5MB for history)

### User Experience
- **Navigation:** Significantly faster with zoxide + fzf
- **Command Recall:** Much better with enhanced history search
- **File Operations:** Faster with fuzzy finding
- **Discoverability:** Better completion suggestions

### Maintenance
- **Complexity:** Slight increase (more features)
- **Debugging:** Easier with diagnostic tools
- **Security:** Improved with permission checks

---

## Next Steps

1. **Review this document** and decide which improvements to implement
2. **Answer the decision questions** above
3. **Prioritize changes** - which phase to start with?
4. **Test incrementally** - apply changes in small batches
5. **Iterate** - refine based on daily usage

---

## References

- [FZF Documentation](https://github.com/junegunn/fzf)
- [Zsh Options](http://zsh.sourceforge.net/Doc/Release/Options.html)
- [Prezto Modules](https://github.com/sorin-ionescu/prezto)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [bat](https://github.com/sharkdp/bat)

---

**Ready to proceed?** Let me know which improvements you'd like to implement first!
