# ========================================
# Zsh Configuration File
# ========================================

# ========================================
# Agent Setup
# ========================================

# Start ssh-agent on login (Linux-specific)
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if command -v keychain &> /dev/null; then
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
      /usr/bin/keychain --nogui "$HOME/.ssh/id_ed25519"
    elif [[ -f "$HOME/.ssh/id_rsa" ]]; then
      /usr/bin/keychain --nogui "$HOME/.ssh/id_rsa"
    fi
    [[ -f "$HOME/.keychain/$(hostname)-sh" ]] && source "$HOME/.keychain/$(hostname)-sh"
  fi
fi

# Start gpg-agent if available
if command -v gpg-connect-agent &> /dev/null; then
  export GPG_TTY=$(tty)
  gpg-connect-agent updatestartuptty /bye &> /dev/null
fi

# ========================================
# System Information
# ========================================

# Display system info with fastfetch if available
if command -v fastfetch &> /dev/null; then
  fastfetch
fi

# ========================================
# Prompt Configuration
# ========================================

# Enable Powerlevel10k instant prompt
# Should stay close to the top of ~/.zshrc
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========================================
# Zsh Framework
# ========================================

# Source Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# ========================================
# Environment Variables
# ========================================

# Set terminal type
export TERM=xterm-256color

# Set editor variables
if command -v nvim &> /dev/null; then
  export EDITOR=nvim
  export VISUAL=nvim
else
  export EDITOR=vim
  export VISUAL=vim
fi

# Set Kubernetes config
if [[ -f "$HOME/.kube/config" ]]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

# ========================================
# PATH Configuration
# ========================================

# Add local bin to PATH
if [[ -d "$HOME/.local/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH="$PATH:$HOME/.local/bin"
fi

# Homebrew setup (OS-specific)
if [[ "$OSTYPE" == "darwin"* ]]; then
  brew_prefix="/opt/homebrew"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  brew_prefix="/home/linuxbrew/.linuxbrew"
fi
if [[ -n "$brew_prefix" ]] && [[ -d "$brew_prefix" ]]; then
  eval "$($brew_prefix/bin/brew shellenv)"
fi

# Add Node.js to PATH
if [[ -d "/opt/homebrew/opt/node@22/bin" ]]; then
  export PATH="/opt/homebrew/opt/node@22/bin:$PATH"
fi

# ========================================
# Tool Configurations
# ========================================

# Set LS_COLORS with vivid
if command -v vivid &> /dev/null; then
  export LS_COLORS="$(vivid generate molokai)"
fi

# macOS-specific ls alias
if [[ "$OSTYPE" == "darwin"* ]] && [[ -x "/opt/homebrew/bin/gls" ]]; then
  alias ls="/opt/homebrew/bin/gls --color"
fi

# ========================================
# Aliases and Keybindings
# ========================================

# Source custom aliases
if [[ -f "$HOME/.aliases" ]]; then
  source "$HOME/.aliases"
fi

# History search keybinding
bindkey '^R' history-incremental-search-backward

# ========================================
# Powerlevel10k Configuration
# ========================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ========================================
# End of Configuration
# ========================================