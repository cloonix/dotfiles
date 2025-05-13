#!/bin/sh

GIT_HOME="$HOME/git"
DOTFILES="$HOME/git/dotfiles"

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

# Ensure chsh uses $USER and checks for zsh availability
# This replaces any older hardcoded chsh command
# Change default shell to zsh for user $USER without prompting
if command -v zsh >/dev/null 2>&1; then
  sudo chsh -s "$(which zsh)" "$USER"
else
  echo "zsh not found. Cannot change default shell."
fi

<<<<<<< Updated upstream
ln -fs ./git/dotfiles/.zprezto/runcoms/.zpreztorc $HOME/.zpreztorc
ln -fs ./git/dotfiles/.gitconfig $HOME/.gitconfig
ln -fs ./git/dotfiles/.aliases $HOME/.aliases
=======
# Ensure symlinks for .zpreztorc, .gitconfig, .aliases are robust
# This replaces older, potentially problematic symlink commands

# Symlink custom prezto configuration if it exists in dotfiles
# This will overwrite the default prezto symlink for .zpreztorc
if [ -f "$(pwd)/.zpreztorc" ]; then
  ln -fs "$(pwd)/.zpreztorc" "$HOME/.zpreztorc"
fi

# Symlink other config files from dotfiles repo
if [ -f "$(pwd)/.gitconfig" ]; then
  ln -fs "$(pwd)/.gitconfig" "$HOME/.gitconfig"
fi
if [ -f "$(pwd)/.aliases" ]; then
  ln -fs "$(pwd)/.aliases" "$HOME/.aliases"
fi
>>>>>>> Stashed changes
