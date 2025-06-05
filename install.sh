#!/bin/zsh 
echo "ZSH_VERSION is: '$ZSH_VERSION'" # Will be set if in zsh

# Prompt for GitHub username and setup SSH authorized keys
echo "Setting up SSH authorized keys from GitHub..."
read "github_username?Enter your GitHub username: "

if [[ -n "$github_username" ]]; then
  SSH_DIR="$HOME/.ssh"
  AUTHORIZED_KEYS_FILE="$SSH_DIR/authorized_keys"
  
  # Create .ssh directory if it doesn't exist
  mkdir -p "$SSH_DIR"
  
  # Download public keys from GitHub
  echo "Downloading public keys for user: $github_username"
  if curl -fsSL "https://github.com/$github_username.keys" -o /tmp/github_keys 2>/dev/null; then
    if [[ -s /tmp/github_keys ]]; then
      # Backup existing authorized_keys if it exists
      if [[ -f "$AUTHORIZED_KEYS_FILE" ]]; then
        cp "$AUTHORIZED_KEYS_FILE" "$AUTHORIZED_KEYS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        echo "Backed up existing authorized_keys file"
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
      
      echo "✓ Successfully added $added_count new GitHub SSH keys to $AUTHORIZED_KEYS_FILE"
    else
      echo "⚠ No public keys found for GitHub user: $github_username"
    fi
  else
    echo "✗ Failed to download keys for GitHub user: $github_username"
  fi
  
  # Clean up temporary file
  rm -f /tmp/github_keys
else
  echo "No GitHub username provided, skipping SSH key setup"
fi

echo ""

GIT_HOME="$HOME/git"
DOTFILES="$HOME/git/dotfiles"

# Check for required binaries
# Use zsh array for robustness as this code runs in zsh
required_binaries_list=(git curl vim tmux sudo zsh nvim)
missing_binaries_list=() # Initialize as an empty zsh array

echo "Checking for required binaries..."
for bin_to_check in "${required_binaries_list[@]}"; do
  if command -v "$bin_to_check" >/dev/null 2>&1; then
    echo "✓ $bin_to_check found"
  else
    echo "✗ $bin_to_check missing"
    missing_binaries_list+=("$bin_to_check")
  fi
done

if (( ${#missing_binaries_list[@]} > 0 )); then # Check if array is not empty
  echo ""
  echo "Error: The following required binaries are missing:"
  for missing_bin in "${missing_binaries_list[@]}"; do # Iterate over array
    echo "  - $missing_bin"
  done
  exit 1
fi

echo "All required binaries found. Proceeding with installation..."
echo ""

# Setting up nvim

# Uninstall existing NvChad/Neovim config
echo "🧹 Cleaning up existing configuration..."
echo "  Removing ~/.config/nvim"
rm -rf ~/.config/nvim
echo "  Removing ~/.local/state/nvim"
rm -rf ~/.local/state/nvim
echo "  Removing ~/.local/share/nvim"
rm -rf ~/.local/share/nvim
echo "  Removing ~/.cache/nvim"
rm -rf ~/.cache/nvim
echo "✅ Cleanup completed"

echo "📥 Cloning NvChad starter template..."
git clone https://github.com/NvChad/starter ~/.config/nvim

# Install plugins and language servers
echo "🔧 Installing plugins and language servers..."
echo "This may take a few minutes..."

# Run Neovim with plugin installation and Mason setup
nvim --headless -c "Lazy! sync" -c "qa"
sleep 2
nvim --headless -c "MasonInstallAll" -c "qa"

echo "🔗 Creating symlink for nvim config..."
ln -fs $GIT_HOME/dotfiles/nvim/init.lua ~/.config/nvim/init.lua


# Setting up vim ...
cd $DOTFILES
if [ ! -d "$GIT_HOME/iceberg.vim" ]; then
  echo "Cloning iceberg.vim ..."
  git clone https://github.com/cocopon/iceberg.vim.git ../iceberg.vim
fi
mkdir -p $HOME/.vim/colors
ln -fs $GIT_HOME/iceberg.vim/colors/iceberg.vim $HOME/.vim/colors/iceberg.vim
ln -fs $(pwd)/.vimrc $HOME/.vimrc
curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qa

# Setting up tmux ...
ln -fs $(pwd)/.tmux.conf ~/.tmux.conf
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  echo "Cloning tmux plugin manager ..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi 
# start a server but don't attach to it
tmux start-server
# create a new session but don't attach to it either
tmux new-session -d
sleep 1
# install the plugins
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
# kill server
tmux kill-server

ln -fs $(pwd)/.zshrc ~/.zshrc
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Cloning prezto ..."
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
fi
# Ensure prezto runcoms are symlinked correctly after prezto clone
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -fs "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

sudo chsh -s "$(which zsh)" "$USER"

ln -fs ./git/dotfiles/.zprezto/runcoms/.zpreztorc $HOME/.zpreztorc
ln -fs ./git/dotfiles/.zshrc $HOME/.zshrc
ln -fs ./git/dotfiles/.gitconfig $HOME/.gitconfig
ln -fs ./git/dotfiles/.aliases $HOME/.aliases
ln -fs ./git/dotfiles/.p10k.zsh $HOME/.p10k.zsh

if [[ "$(uname)" == "Darwin" ]]; then
  GHOSTTY_CONFIG_DIR="$HOME/Library/Application Support/com.mitchellh.ghostty"
  mkdir -p "$GHOSTTY_CONFIG_DIR"
  ln -fs "$DOTFILES/ghostty/config" "$GHOSTTY_CONFIG_DIR/config"
fi
