#!/bin/zsh 

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Visual formatting functions
print_header() {
    echo -e "\n${CYAN}${BOLD}================================================${NC}"
    echo -e "${WHITE}${BOLD}  $1${NC}"
    echo -e "${CYAN}${BOLD}================================================${NC}\n"
}

print_section() {
    echo -e "\n${PURPLE}${BOLD}▶ $1${NC}"
    echo -e "${PURPLE}═══════════════════════════════════════════════════════════════${NC}"
}

print_success() {
    echo -e "  ${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "  ${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "  ${RED}❌ $1${NC}"
}

print_info() {
    echo -e "  ${BLUE}→ $1${NC}"
}

print_header "🚀 Dotfiles Installation Script"
echo -e "${CYAN}Running under zsh (version: ${BOLD}$ZSH_VERSION${NC}${CYAN})${NC}\n"

# Check if running inside a tmux session
if [[ -n "$TMUX" ]]; then
    print_error "This script cannot be run from within an active tmux session"
    echo -e "${YELLOW}Please exit tmux and run the script from a regular terminal.${NC}"
    echo -e "${CYAN}You can exit tmux by typing: ${BOLD}exit${NC}${CYAN} or ${BOLD}Ctrl+d${NC}"
    exit 1
fi

print_section "🔑 Setting up SSH authorized keys from GitHub"
echo -e -n "${CYAN}Enter your GitHub username: ${NC}"
read github_username

if [[ -n "$github_username" ]]; then
  SSH_DIR="$HOME/.ssh"
  AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
  
  # Create .ssh directory if it doesn't exist
  mkdir -p "$SSH_DIR"
  
  # Download public keys from GitHub
  print_info "Downloading public keys for user: $github_username..."
  if curl -fsSL "https://github.com/$github_username.keys" -o /tmp/github_keys 2>/dev/null; then
    if [[ -s /tmp/github_keys ]]; then
      # Backup existing authorized_keys if it exists
      if [[ -f "$AUTHORIZED_KEYS_FILE" ]]; then
        cp "$AUTHORIZED_KEYS_FILE" "$AUTHORIZED_KEYS_FILE.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null
        print_info "Backed up existing authorized_keys file"
      fi
      
      # Check for duplicate keys and add only new ones
      added_count=0
      while IFS= read -r key; do
        if [[ -n "$key" && ! -f "$AUTHORIZED_KEYS_FILE" ]] || ! grep -Fxq "$key" "$AUTHORIZED_KEYS_FILE" 2>/dev/null; then
          echo "$key" >> "$AUTHORIZED_KEYS_FILE"
          ((added_count++))
        fi
      done < /tmp/github_keys
      
      # Set proper permissions
      chmod 700 "$SSH_DIR"
      chmod 600 "$AUTHORIZED_KEYS_FILE"
      
      print_success "Successfully added $added_count new GitHub SSH keys"
    else
      print_warning "No public keys found for GitHub user: $github_username"
    fi
  else
    print_error "Failed to download keys for GitHub user: $github_username"
  fi
  
  # Clean up temporary file
  rm -f /tmp/github_keys
else
  print_warning "No GitHub username provided, skipping SSH key setup"
fi

# Verify we're in the right directory
if [[ ! -d "$HOME/git/dotfiles" ]]; then
    print_error "Dotfiles directory not found at $HOME/git/dotfiles" >&2
    echo -e "${YELLOW}Please ensure you've cloned the dotfiles repository first:${NC}" >&2
    echo -e "  ${CYAN}mkdir -p $HOME/git && cd $HOME/git${NC}" >&2
    echo -e "  ${CYAN}git clone <your-dotfiles-repo-url> dotfiles${NC}" >&2
    exit 1
fi

GIT_HOME="$HOME/git"
DOTFILES="$HOME/git/dotfiles"

# Check for required binaries
# Use zsh array for robustness as this code runs in zsh
required_binaries_list=(git curl vim tmux sudo zsh)
missing_binaries_list=() # Initialize as an empty zsh array

print_section "🔍 Checking for required binaries"
for bin_to_check in "${required_binaries_list[@]}"; do
  if command -v "$bin_to_check" >/dev/null 2>&1; then
    print_success "$bin_to_check found"
  else
    print_error "$bin_to_check missing"
    missing_binaries_list+=("$bin_to_check")
  fi
done

if (( ${#missing_binaries_list[@]} > 0 )); then # Check if array is not empty
  echo ""
  print_error "The following required binaries are missing:"
  for missing_bin in "${missing_binaries_list[@]}"; do # Iterate over array
    echo -e "    ${RED}- $missing_bin${NC}"
  done
  echo ""
  echo -e "${YELLOW}Please install the missing binaries and try again.${NC}"
  echo -e "${CYAN}On Ubuntu/Debian: ${BOLD}sudo apt update && sudo apt install <missing packages>${NC}"
  echo -e "${CYAN}On macOS: ${BOLD}brew install <missing packages>${NC}"
  exit 1
fi

print_success "All required binaries found. Proceeding with installation..."

print_section "🔍 Checking for optional binaries"
nvim_setup=false
if command -v nvim >/dev/null 2>&1; then
  nvim_version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
  if [[ -n "$nvim_version" ]]; then
    major_version=$(echo "$nvim_version" | cut -d. -f1)
    minor_version=$(echo "$nvim_version" | cut -d. -f2)
    if (( major_version > 0 )) || (( major_version == 0 && minor_version >= 11 )); then
      print_success "nvim version $nvim_version meets requirements (0.11+)"
      
      # Check for nvim-specific required binaries
      nvim_required_binaries=(fzf fd)
      nvim_missing_binaries=()
      
      print_info "Checking for nvim-specific required binaries..."
      for bin_to_check in "${nvim_required_binaries[@]}"; do
        if command -v "$bin_to_check" >/dev/null 2>&1; then
          echo -e "    ${GREEN}✅ $bin_to_check found${NC}"
        else
          echo -e "    ${RED}❌ $bin_to_check missing${NC}"
          nvim_missing_binaries+=("$bin_to_check")
        fi
      done
      
      if (( ${#nvim_missing_binaries[@]} > 0 )); then
        echo ""
        print_error "nvim is available but the following required binaries are missing:"
        for missing_bin in "${nvim_missing_binaries[@]}"; do
          echo -e "    ${RED}- $missing_bin${NC}"
        done
        echo ""
        echo -e "${YELLOW}Please install the missing binaries and try again.${NC}"
        echo -e "${CYAN}On Ubuntu/Debian: ${BOLD}sudo apt update && sudo apt install <missing packages>${NC}"
        echo -e "${CYAN}On macOS: ${BOLD}brew install <missing packages>${NC}"
        exit 1
      fi
      
      nvim_setup=true
    else
      print_warning "nvim version $nvim_version found, but version 0.11+ required for setup"
    fi
  else
    print_warning "Could not determine nvim version"
  fi
else
  print_warning "nvim not found - will skip nvim configuration"
fi

print_section "📦 Setting up Neovim"
if [[ "$nvim_setup" == true ]]; then
  print_info "Cleaning up existing configuration..."
  rm -rf ~/.config/nvim >/dev/null 2>&1
  rm -rf ~/.local/state/nvim >/dev/null 2>&1
  rm -rf ~/.local/share/nvim >/dev/null 2>&1
  rm -rf ~/.cache/nvim >/dev/null 2>&1
  
  print_info "Creating symlink for nvim config..."
  mkdir -p ~/.config >/dev/null 2>&1
  ln -fs $GIT_HOME/dotfiles/nvim ~/.config/nvim

  print_info "Installing nvim plugins..."
  nvim --headless -c "qa" >/dev/null 2>&1
  
  print_info "Running LazyHealth check..."
  if nvim --headless -c "LazyHealth" -c "qa" >/dev/null 2>&1; then
    echo -e "    ${GREEN}✅ LazyHealth check passed${NC}"
  else
    echo -e "    ${YELLOW}⚠️ LazyHealth check failed${NC}"
  fi
  print_success "Neovim setup completed"
else
  print_warning "Skipping nvim setup (version requirement not met)"
fi


print_section "🔧 Setting up vim"
cd "$DOTFILES"
if [ ! -d "$GIT_HOME/iceberg.vim" ]; then
  print_info "Cloning iceberg.vim theme..."
  git clone https://github.com/cocopon/iceberg.vim.git ../iceberg.vim >/dev/null 2>&1
fi
mkdir -p "$HOME/.vim/colors"
ln -fs "$GIT_HOME/iceberg.vim/colors/iceberg.vim" "$HOME/.vim/colors/iceberg.vim"
ln -fs "$DOTFILES/.vimrc" "$HOME/.vimrc"
echo "  → Installing vim-plug..."
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1
print_info "Installing vim plugins..."
vim +'PlugInstall --sync' +qa >/dev/null 2>&1
print_success "Vim setup completed"

print_section "🔧 Setting up tmux"
ln -fs "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  print_info "Cloning tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1
fi 
print_info "Installing tmux plugins..."
# start a server but don't attach to it
tmux start-server >/dev/null 2>&1
# create a new session but don't attach to it either
tmux new-session -d >/dev/null 2>&1
sleep 1
# install the plugins
tmux source "$HOME/.tmux.conf" >/dev/null 2>&1
"$HOME/.tmux/plugins/tpm/scripts/install_plugins.sh" >/dev/null 2>&1
# kill server
tmux kill-server >/dev/null 2>&1
print_success "Tmux setup completed"

print_section "🔧 Setting up zsh and dotfiles"
print_info "Creating initial zshrc symlink..."
ln -fs $(pwd)/.zshrc ~/.zshrc
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  print_info "Cloning prezto framework..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" >/dev/null 2>&1
fi
print_info "Creating prezto symlinks..."
# Ensure prezto runcoms are symlinked correctly after prezto clone
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

print_info "Checking default shell..."
if command -v getent >/dev/null 2>&1; then
    current_shell=$(getent passwd "$USER" | cut -d: -f7)
else
    current_shell=$(dscl . -read /Users/"$USER" UserShell 2>/dev/null | awk '{print $2}')
fi
zsh_path=$(which zsh)

if [[ "$current_shell" != "$zsh_path" ]]; then
  print_info "Changing default shell to zsh..."
  sudo chsh -s "$zsh_path" "$USER" >/dev/null 2>&1
else
  print_success "Default shell is already zsh"
fi

print_info "Creating dotfiles symlinks..."
ln -fs ./git/dotfiles/.zprezto/runcoms/.zpreztorc $HOME/.zpreztorc
ln -fs ./git/dotfiles/.zshrc $HOME/.zshrc
ln -fs ./git/dotfiles/.gitconfig $HOME/.gitconfig
ln -fs ./git/dotfiles/.aliases $HOME/.aliases
ln -fs ./git/dotfiles/.p10k.zsh $HOME/.p10k.zsh

print_info "Setting up yazi configuration..."
mkdir -p ~/.config/yazi
ln -fs "$DOTFILES/yazi" ~/.config/yazi/
if command -v yazi >/dev/null 2>&1; then
    print_info "Installing yazi plugins and flavors..."
    yazi --clear-cache >/dev/null 2>&1 || true
    # The plugins will be automatically downloaded when yazi starts with the package.toml configuration
    print_success "Yazi configuration completed (plugins will install on first run)"
else
    print_warning "yazi not found - configuration symlinked but plugins won't install until yazi is available"
fi

if [[ "$(uname)" == "Darwin" ]]; then
  print_info "Setting up Ghostty config for macOS..."
  GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_CONFIG_DIR"
  ln -fs "$DOTFILES/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
fi
print_success "Zsh and dotfiles setup completed"

print_header "🎉 Installation completed successfully!"
echo -e "${GREEN}${BOLD}Next steps:${NC}"
echo -e "${CYAN}• Restart your shell or run ${BOLD}'source ~/.zshrc'${NC}${CYAN} to apply changes${NC}"
echo -e "${CYAN}• Open ${BOLD}nvim${NC}${CYAN} to let plugins finish installing${NC}"
echo -e "${CYAN}• Enjoy your new dotfiles setup! ${NC}🚀"
