#!/bin/zsh

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m'

# Helper functions
log() { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✅${NC} $1"; }
warn() { echo -e "${YELLOW}⚠️${NC} $1"; }
error() { echo -e "${RED}❌${NC} $1"; exit 1; }
header() { echo -e "\n${CYAN}${BOLD}=== $1 ===${NC}"; }

# Check binaries
check_binaries() {
    local required=("$@")
    local missing=()
    
    for bin in "${required[@]}"; do
        if command -v "$bin" >/dev/null 2>&1; then
            success "$bin found"
        else
            error "$bin missing"
            missing+=("$bin")
        fi
    done
    
    if (( ${#missing[@]} > 0 )); then
        error "Missing binaries: ${missing[*]}"
    fi
}

# Create symlink with backup
link_file() {
    local src="$1" dest="$2"
    [[ -e "$dest" && ! -L "$dest" ]] && mv "$dest" "${dest}.backup.$(date +%s)"
    mkdir -p "$(dirname "$dest")"
    rm -rf "$dest"
    ln -fs "$src" "$dest"
    success "Linked: $(basename "$dest")"
}

# Setup SSH keys from GitHub
setup_ssh() {
    header "SSH Setup"
    echo -n "GitHub username (or skip): "
    read github_username
    
    [[ -z "$github_username" ]] && { warn "Skipping SSH setup"; return; }
    
    local ssh_dir="$HOME/.ssh"
    local auth_file="$ssh_dir/authorized_keys"
    
    mkdir -p "$ssh_dir"
    
    if curl -fsSL "https://github.com/$github_username.keys" -o /tmp/github_keys 2>/dev/null && [[ -s /tmp/github_keys ]]; then
        [[ -f "$auth_file" ]] && cp "$auth_file" "${auth_file}.backup.$(date +%s)"
        
        local added=0
        while IFS= read -r key; do
            if [[ -n "$key" ]] && ! grep -Fxq "$key" "$auth_file" 2>/dev/null; then
                echo "$key" >> "$auth_file"
                ((added++))
            fi
        done < /tmp/github_keys
        
        chmod 700 "$ssh_dir" && chmod 600 "$auth_file"
        success "Added $added SSH keys"
        rm -f /tmp/github_keys
    else
        warn "No keys found for: $github_username"
    fi
}

# Main installation
main() {
    [[ -n "$TMUX" ]] && error "Cannot run inside tmux session"
    [[ ! -d "$HOME/git/dotfiles" ]] && error "Dotfiles not found at $HOME/git/dotfiles"
    
    header "🚀 Dotfiles Installation"
    log "Running zsh version: $ZSH_VERSION"
    
    local DOTFILES="$HOME/git/dotfiles"
    cd "$DOTFILES"
    
    # SSH setup
    setup_ssh
    
    # Check required binaries
    header "Checking Dependencies"
    check_binaries git curl vim tmux zsh
    
    # Optional: Check nvim
    local nvim_setup=false
    if command -v nvim >/dev/null 2>&1; then
        local version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
        local major=$(echo "$version" | cut -d. -f1)
        local minor=$(echo "$version" | cut -d. -f2)
        
        if (( major > 0 || (major == 0 && minor >= 11) )); then
            check_binaries fzf fd
            nvim_setup=true
            success "nvim $version ready"
        else
            warn "nvim $version < 0.11, skipping"
        fi
    else
        warn "nvim not found"
    fi
    
    # Setup configurations
    header "Setting up configurations"
    
    # Neovim
    if [[ "$nvim_setup" == true ]]; then
        log "Setting up nvim"
        rm -rf ~/.config/nvim ~/.local/{state,share,cache}/nvim
        link_file "$DOTFILES/nvim" "$HOME/.config/nvim"
        
        log "Installing nvim plugins..."
        # Install plugins with Lazy
        nvim --headless -c "Lazy! sync" -c "qa" >/dev/null 2>&1
        
        log "Installing LSPs and tools..."
        # Install Mason tools if MasonInstallAll command exists
        nvim --headless -c "MasonInstallAll" -c "qa" >/dev/null 2>&1 || true
        
        success "Neovim configured with plugins"
    fi
    
    # Vim
    log "Setting up vim"
    if [[ ! -d "$HOME/git/iceberg.vim" ]]; then
        git clone https://github.com/cocopon/iceberg.vim.git "$HOME/git/iceberg.vim" >/dev/null 2>&1
    fi
    link_file "$HOME/git/iceberg.vim/colors/iceberg.vim" "$HOME/.vim/colors/iceberg.vim"
    link_file "$DOTFILES/.vimrc" "$HOME/.vimrc"
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1
    vim +'PlugInstall --sync' +qa >/dev/null 2>&1
    
    # Tmux
    log "Setting up tmux"
    link_file "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1
    fi
    tmux start-server >/dev/null 2>&1
    tmux new-session -d >/dev/null 2>&1
    sleep 1
    tmux source "$HOME/.tmux.conf" >/dev/null 2>&1
    "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null 2>&1
    tmux kill-server >/dev/null 2>&1
    
    # Zsh & Prezto
    log "Setting up zsh"
    if [[ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]]; then
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" >/dev/null 2>&1
    fi
    
    setopt EXTENDED_GLOB
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
        link_file "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
    done
    
    # Dotfiles symlinks
    link_file "$DOTFILES/.zshrc" "$HOME/.zshrc"
    link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig"
    link_file "$DOTFILES/.aliases" "$HOME/.aliases"
    link_file "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh"
    link_file "$DOTFILES/.zprezto/runcoms/.zpreztorc" "$HOME/.zpreztorc"
    
    # Yazi
    link_file "$DOTFILES/yazi" "$HOME/.config/yazi"
    ya pkg install
    if command -v yazi >/dev/null 2>&1; then
        yazi --clear-cache >/dev/null 2>&1 || true
        success "Yazi configured"
    else
        warn "yazi not found"
    fi
    
    # Ghostty (macOS only)
    if [[ "$(uname)" == "Darwin" ]]; then
        link_file "$DOTFILES/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
    fi
    
    # Change default shell
    local current_shell zsh_path
    if command -v getent >/dev/null 2>&1; then
        current_shell=$(getent passwd "$USER" | cut -d: -f7)
    else
        current_shell=$(dscl . -read "/Users/$USER" UserShell 2>/dev/null | awk '{print $2}')
    fi
    zsh_path=$(which zsh)
    
    if [[ "$current_shell" != "$zsh_path" ]]; then
        log "Changing shell to zsh"
        sudo chsh -s "$zsh_path" "$USER" >/dev/null 2>&1
    fi
    
    header "🎉 Installation Complete!"
    echo -e "${CYAN}• Run: ${BOLD}source ~/.zshrc${NC}"
    echo -e "${CYAN}• Open nvim to finish plugin setup${NC}"
}

main "$@"
