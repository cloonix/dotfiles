# My dotfiles

## Requirements

Install the packages and re-generate the fonts cache

```sh
sudo apt install curl vim tmux git zsh fonts-powerline
sudo fc-cache -fv
```

For git:

```sh
ln -fs $(pwd)/.gitconfig ~/.gitconfig
```

For vim:

```sh
git clone https://github.com/cocopon/iceberg.vim.git ../iceberg.vim
mkdir -p ~/.vim/colors
ln -s ~/git/iceberg.vim/colors/iceberg.vim ~/.vim/colors/iceberg.vim
ln -fs $(pwd)/.vimrc ~/.vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +PlugInstall +qa +silent
```

For tmux:

```sh
ln -fs $(pwd)/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
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
```

For zsh:

Switch to zsh before executing. 

```sh
ln -fs $(pwd)/.zshrc ~/.zshrc
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
    ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
chsh -s $(which zsh)
```	

Manually set the theme in `~/.zpreztorc`. E. g. `agnoster`
