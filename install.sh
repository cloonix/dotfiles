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

# Progress function for "Configuring xyz ... finished ✅"
progress() {
    local task="$1"
    echo -n "Configuring $task ... "
}

finish() {
    echo -e "finished ${GREEN}✅${NC}"
}

failed() {
    echo -e "failed ${RED}❌${NC}"
}

# Check dependencies with platform-specific install instructions
check_dependencies() {
    local required=("$@")
    local missing=()
    local platform
    
    # Detect platform
    if [[ "$OSTYPE" == "darwin"* ]]; then
        platform="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        platform="linux"
    else
        platform="unknown"
    fi
    
    # Check each binary
    for bin in "${required[@]}"; do
        if command -v "$bin" >/dev/null 2>&1; then
            success "$bin found"
        else
            warn "$bin missing"
            missing+=("$bin")
        fi
    done
    
    if (( ${#missing[@]} > 0 )); then
        echo -e "\n${RED}❌ Missing dependencies:${NC}"
        printf '  - %s\n' "${missing[@]}"
        
        echo -e "\n${CYAN}${BOLD}=== Installation Instructions ===${NC}"
        
        case $platform in
            "macos")
                echo -e "${GREEN}macOS (Homebrew):${NC}"
                echo "  brew install ${missing[*]}"
                ;;
            "linux")
                echo -e "${GREEN}Ubuntu/Debian:${NC}"
                echo "  sudo apt update && sudo apt install ${missing[*]}"
                echo -e "\n${GREEN}CentOS/RHEL/Fedora:${NC}"
                echo "  sudo yum install ${missing[*]}"
                echo "  # or: sudo dnf install ${missing[*]}"
                ;;
            *)
                echo -e "${YELLOW}Platform-specific installation:${NC}"
                echo "  Please install: ${missing[*]}"
                ;;
        esac
        
        echo ""
        return 1
    fi
    
    return 0
}

# Create symlink with backup
link_file() {
    local src="$1" dest="$2"
    [[ -e "$dest" && ! -L "$dest" ]] && mv "$dest" "${dest}.backup.$(date +%s)" 2>/dev/null
    mkdir -p "$(dirname "$dest")" 2>/dev/null || return 1
    rm -rf "$dest" 2>/dev/null || return 1
    ln -fs "$src" "$dest" 2>/dev/null || return 1
    return 0
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

    # Reset repository to fresh state
    header "Resetting Repository"
    log "Cleaning untracked files and directories"
    git clean -fdx
    
    # SSH setup
    setup_ssh
    
    # Check required binaries
    header "Checking Dependencies"
    check_dependencies git curl vim tmux zsh
    
    # Optional: Check nvim and related tools
    local nvim_setup=false
    if command -v nvim >/dev/null 2>&1; then
        local version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
        local major=$(echo "$version" | cut -d. -f1)
        local minor=$(echo "$version" | cut -d. -f2)
        
        if (( major > 0 || (major == 0 && minor >= 11) )); then
            check_dependencies fzf fd
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
        progress "Neovim"
        if rm -rf ~/.config/nvim ~/.local/{state,share,cache}/nvim 2>/dev/null && \
           link_file "$DOTFILES/nvim" "$HOME/.config/nvim" && \
           nvim --headless -c "Lazy! sync" -c "qa" >/dev/null 2>&1; then
            # Install Mason tools if MasonInstallAll command exists
            nvim --headless -c "MasonInstallAll" -c "qa" >/dev/null 2>&1 || true
            finish
        else
            failed
        fi
    fi
    
    # Vim
    progress "Vim"
    if { [[ -d "$HOME/git/iceberg.vim" ]] || git clone https://github.com/cocopon/iceberg.vim.git "$HOME/git/iceberg.vim" >/dev/null 2>&1; } && \
       link_file "$HOME/git/iceberg.vim/colors/iceberg.vim" "$HOME/.vim/colors/iceberg.vim" && \
       link_file "$DOTFILES/.vimrc" "$HOME/.vimrc" && \
       curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1 && \
       vim +'PlugInstall --sync' +qa >/dev/null 2>&1; then
        finish
    else
        failed
    fi
    
    # Tmux
    progress "Tmux"
    if link_file "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf" && \
       { [[ -d "$HOME/.tmux/plugins/tpm" ]] || git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1; } && \
       tmux start-server >/dev/null 2>&1 && \
       tmux new-session -d >/dev/null 2>&1 && \
       sleep 1 && \
       tmux source "$HOME/.tmux.conf" >/dev/null 2>&1 && \
       "$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null 2>&1 && \
       tmux kill-server >/dev/null 2>&1; then
        finish
    else
        failed
    fi
    
    # Zsh & Prezto
    progress "Zsh"
    if { [[ -d "${ZDOTDIR:-$HOME}/.zprezto" ]] || git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" >/dev/null 2>&1; }; then
        setopt EXTENDED_GLOB
        local success_flag=true
        for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
            link_file "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}" || success_flag=false
        done
        
        # Dotfiles symlinks
        link_file "$DOTFILES/.zshrc" "$HOME/.zshrc" && \
        link_file "$DOTFILES/.gitconfig" "$HOME/.gitconfig" && \
        link_file "$DOTFILES/.gitconfig-github" "$HOME/.gitconfig-github" && \
        link_file "$DOTFILES/.gitconfig-gitlab" "$HOME/.gitconfig-gitlab" && \
        link_file "$DOTFILES/.aliases" "$HOME/.aliases" && \
        link_file "$DOTFILES/.p10k.zsh" "$HOME/.p10k.zsh" && \
        link_file "$DOTFILES/.zprezto/runcoms/.zpreztorc" "$HOME/.zpreztorc" && \
        link_file "$DOTFILES/.markdownlint-cli2.yaml" "$HOME/.markdownlint-cli2.yaml" || success_flag=false
        
        if [[ "$success_flag" == true ]]; then
            finish
        else
            failed
        fi
    else
        failed
    fi
    
    # Yazi
    progress "Yazi"
    if link_file "$DOTFILES/yazi" "$HOME/.config/yazi" && \
       ya pkg install >/dev/null 2>&1 && \
       command -v yazi >/dev/null 2>&1; then
        yazi --clear-cache >/dev/null 2>&1 || true
        finish
    else
        failed
        warn "yazi not found or installation failed"
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
