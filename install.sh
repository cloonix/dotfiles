#!/bin/sh

GIT_HOME="$HOME/git"
DOTFILES="$HOME/git/dotfiles"

# Check for required binaries
required_binaries="git curl vim tmux sudo chsh zsh"
missing_binaries=""

for bin in $required_binaries; do
  if ! command -v "$bin" >/dev/null 2>&1; then
    missing_binaries="$missing_binaries $bin"
  fi
done

if [ -n "$missing_binaries" ]; then
  echo "Error: The following required binaries are not installed or not in PATH:"
  echo "$missing_binaries"
  echo "Please install them and try again."
  exit 1
fi

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

if [ -z "$ZSH_VERSION" ]; then
    echo "Switching to zsh..."
    exec zsh "$0" "$@"
fi

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