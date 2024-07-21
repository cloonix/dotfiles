#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# start ssh-agent on login
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
  /usr/bin/keychain --nogui $HOME/.ssh/id_rsa
else
  /usr/bin/keychain --nogui $HOME/.ssh/id_ed25519
fi

source $HOME/.keychain/$(hostname)-sh