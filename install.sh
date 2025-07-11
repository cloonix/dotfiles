#!/bin/zsh 
echo "🚀 Dotfiles Installation Script"
echo "================================"
echo "Running under zsh (version: $ZSH_VERSION)"
echo ""

# Prompt for GitHub username and setup SSH authorized keys
echo "🔑 Setting up SSH authorized keys from GitHub..."
read "github_username?Enter your GitHub username: "

if [[ -n "$github_username" ]]; then
  SSH_DIR="$HOME/.ssh"
  AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
  
  # Create .ssh directory if it doesn't exist
  mkdir -p "$SSH_DIR"
  
  # Download public keys from GitHub
  echo "  → Downloading public keys for user: $github_username..."
  if curl -fsSL "https://github.com/$github_username.keys" -o /tmp/github_keys 2>/dev/null; then
    if [[ -s /tmp/github_keys ]]; then
      # Backup existing authorized_keys if it exists
      if [[ -f "$AUTHORIZED_KEYS_FILE" ]]; then
        cp "$AUTHORIZED_KEYS_FILE" "$AUTHORIZED_KEYS_FILE.backup.$(date +%Y%m%d_%H%M%S)" 2>/dev/null
        echo "  → Backed up existing authorized_keys file"
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
      
      echo "  ✅ Successfully added $added_count new GitHub SSH keys"
    else
      echo "  ⚠️ No public keys found for GitHub user: $github_username"
    fi
  else
    echo "  ❌ Failed to download keys for GitHub user: $github_username"
  fi
  
  # Clean up temporary file
  rm -f /tmp/github_keys
else
  echo "  ⏭️ No GitHub username provided, skipping SSH key setup"
fi

echo ""

# Verify we're in the right directory
if [[ ! -d "$HOME/git/dotfiles" ]]; then
    echo "❌ Error: Dotfiles directory not found at $HOME/git/dotfiles" >&2
    echo "Please ensure you've cloned the dotfiles repository first:" >&2
    echo "  mkdir -p $HOME/git && cd $HOME/git" >&2
    echo "  git clone <your-dotfiles-repo-url> dotfiles" >&2
    exit 1
fi

GIT_HOME="$HOME/git"
DOTFILES="$HOME/git/dotfiles"

# Check for required binaries
# Use zsh array for robustness as this code runs in zsh
required_binaries_list=(git curl vim tmux sudo zsh)
missing_binaries_list=() # Initialize as an empty zsh array

echo "🔍 Checking for required binaries..."
for bin_to_check in "${required_binaries_list[@]}"; do
  if command -v "$bin_to_check" >/dev/null 2>&1; then
    echo "  ✅ $bin_to_check found"
  else
    echo "  ❌ $bin_to_check missing"
    missing_binaries_list+=("$bin_to_check")
  fi
done

if (( ${#missing_binaries_list[@]} > 0 )); then # Check if array is not empty
  echo ""
  echo "❌ Error: The following required binaries are missing:"
  for missing_bin in "${missing_binaries_list[@]}"; do # Iterate over array
    echo "    - $missing_bin"
  done
  echo ""
  echo "Please install the missing binaries and try again."
  echo "On Ubuntu/Debian: sudo apt update && sudo apt install <missing packages>"
  echo "On macOS: brew install <missing packages>"
  exit 1
fi

echo "✅ All required binaries found. Proceeding with installation..."

# Check nvim availability and version requirement (optional)
echo "🔍 Checking for optional binaries..."
nvim_setup=false
if command -v nvim >/dev/null 2>&1; then
  nvim_version=$(nvim --version | head -n1 | grep -o 'v[0-9]\+\.[0-9]\+' | sed 's/v//')
  if [[ -n "$nvim_version" ]]; then
    major_version=$(echo "$nvim_version" | cut -d. -f1)
    minor_version=$(echo "$nvim_version" | cut -d. -f2)
    if (( major_version > 0 )) || (( major_version == 0 && minor_version >= 11 )); then
      echo "  ✅ nvim version $nvim_version meets requirements (0.11+)"
      nvim_setup=true
    else
      echo "  ⚠️ nvim version $nvim_version found, but version 0.11+ required for setup"
    fi
  else
    echo "  ⚠️ Could not determine nvim version"
  fi
else
  echo "  ⚠️ nvim not found - will skip nvim configuration"
fi

echo ""

# Setting up nvim
echo "📦 Setting up Neovim..."
if [[ "$nvim_setup" == true ]]; then
  echo "  → Cleaning up existing configuration..."
  rm -rf ~/.config/nvim >/dev/null 2>&1
  rm -rf ~/.local/state/nvim >/dev/null 2>&1
  rm -rf ~/.local/share/nvim >/dev/null 2>&1
  rm -rf ~/.cache/nvim >/dev/null 2>&1
  
  echo "  → Creating symlink for nvim config..."
  mkdir -p ~/.config >/dev/null 2>&1
  ln -fs $GIT_HOME/dotfiles/nvim ~/.config/nvim

  echo "  → Installing plugins and language servers (this may take a few minutes)..."
  if nvim --headless -c "Lazy! sync" -c "qa" >/dev/null 2>&1; then
    echo "    ✅ Lazy plugin sync completed"
  else
    echo "    ⚠️ Lazy plugin sync failed"
  fi
  
  sleep 2
  
  if nvim --headless -c "MasonInstallAll" -c "qa" >/dev/null 2>&1; then
    echo "    ✅ Mason language servers installed"
  else
    echo "    ⚠️ Mason installation failed or MasonInstallAll command not available"
  fi
  echo "  ✅ Neovim setup completed"
else
  echo "  ⏭️ Skipping nvim setup (version requirement not met)"
fi
echo ""


# Setting up vim
echo "🔧 Setting up vim..."
cd "$DOTFILES"
if [ ! -d "$GIT_HOME/iceberg.vim" ]; then
  echo "  → Cloning iceberg.vim theme..."
  git clone https://github.com/cocopon/iceberg.vim.git ../iceberg.vim >/dev/null 2>&1
fi
mkdir -p "$HOME/.vim/colors"
ln -fs "$GIT_HOME/iceberg.vim/colors/iceberg.vim" "$HOME/.vim/colors/iceberg.vim"
ln -fs "$DOTFILES/.vimrc" "$HOME/.vimrc"
echo "  → Installing vim-plug..."
curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim >/dev/null 2>&1
echo "  → Installing vim plugins..."
vim +'PlugInstall --sync' +qa >/dev/null 2>&1
echo "  ✅ Vim setup completed"

# Setting up tmux
echo "🔧 Setting up tmux..."
ln -fs "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "  → Cloning tmux plugin manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm" >/dev/null 2>&1
fi 
echo "  → Installing tmux plugins..."
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
echo "  ✅ Tmux setup completed"

# Setting up zsh and dotfiles
echo "🔧 Setting up zsh and dotfiles..."
echo "  → Creating initial zshrc symlink..."
ln -fs $(pwd)/.zshrc ~/.zshrc
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "  → Cloning prezto framework..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto" >/dev/null 2>&1
fi
echo "  → Creating prezto symlinks..."
# Ensure prezto runcoms are symlinked correctly after prezto clone
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo "  → Changing default shell to zsh..."
sudo chsh -s "$(which zsh)" "$USER" >/dev/null 2>&1

echo "  → Creating dotfiles symlinks..."
ln -fs ./git/dotfiles/.zprezto/runcoms/.zpreztorc $HOME/.zpreztorc
ln -fs ./git/dotfiles/.zshrc $HOME/.zshrc
ln -fs ./git/dotfiles/.gitconfig $HOME/.gitconfig
ln -fs ./git/dotfiles/.aliases $HOME/.aliases
ln -fs ./git/dotfiles/.p10k.zsh $HOME/.p10k.zsh

if [[ "$(uname)" == "Darwin" ]]; then
  echo "  → Setting up Ghostty config for macOS..."
  GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_CONFIG_DIR"
  ln -fs "$DOTFILES/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
fi
echo "  ✅ Zsh and dotfiles setup completed"

echo ""
echo "🎉 Installation completed successfully!"
echo "Please restart your shell or run 'source ~/.zshrc' to apply changes."
