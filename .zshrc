# start ssh-agent on login
if [[ "$OSTYPE" == "linux-gnu"* ]]; then

  if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    /usr/bin/keychain --nogui $HOME/.ssh/id_rsa
  else
    /usr/bin/keychain --nogui $HOME/.ssh/id_ed25519
  fi

  source $HOME/.keychain/$(hostname)-sh
fi

fastfetch

# Enable Powerlevel10k instant prompt. Should stay close to G::::the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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

if [[ -d "$HOME/.local/bin" && ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
  export PATH=$PATH:$HOME/.local/bin
fi

if [[ -d "/home/linuxbrew" && ":$PATH:" != *":/home/linuxbrew:"* ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

source $HOME/.aliases

bindkey '^R' history-incremental-search-backward

export TERM=xterm-256color

if command -v vivid &> /dev/null; then
  export LS_COLORS="$(vivid generate molokai)"
fi
