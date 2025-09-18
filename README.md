# My Dotfiles (2025-09-16)

Personal dotfiles for a modern development environment with automated installation.

## Features

- **Neovim** with LazyVim framework, LSPs, and plugins
- **Vim** with iceberg theme and essential plugins  
- **Zsh** with Prezto framework and PowerLevel10k theme
- **Tmux** with plugin manager and custom configuration
- **Yazi** file manager with plugins and image previews
- **Ghostty** terminal configuration (macOS)
- **Git** configuration with helpful aliases
- Automated SSH key setup from GitHub

## Quick Installation

**Prerequisites:** Ensure you have `zsh` installed and are running the script in zsh.

```bash
# Clone the repository
mkdir -p ~/git && cd ~/git
git clone <your-repo-url> dotfiles
cd dotfiles

# Run the installation script
./install.sh
```

The installation script will:

- Set up SSH authorized keys from your GitHub account
- Check for required dependencies
- Install and configure all applications
- Create proper symlinks
- Set up plugins for vim, tmux, and neovim

## Requirements

### Essential Dependencies

- `git` `curl` `vim` `tmux` `zsh`

### Optional but Recommended

- `nvim` (version 0.11+) - For the full Neovim experience
- `fzf` `fd` - Required for Neovim fuzzy finding
- `glow` - For markdown previews in yazi
- `chafa` - For image previews in yazi
- `vivid` - Enhanced terminal colors
- `keychain` - SSH key management (Linux)

### Installation Commands

**Ubuntu/Debian:**

```bash
sudo apt update && sudo apt install curl vim tmux git zsh keychain vivid
# For desktop environments
sudo apt install fonts-powerline && sudo fc-cache -fv
```

**macOS:**

```bash
brew install nvim fzf fd glow chafa vivid
```

## Configuration Details

### Neovim

- Uses LazyVim framework with Lazy plugin manager
- Leader key: `,`
- Automatic LSP installation via Mason
- Custom plugins for enhanced development

### Yazi File Manager  

- Custom theme: flexoki-dark
- Plugins: glow, jump-to-char, mount, piper
- Image previews with chafa (works in tmux)
- Markdown previews with glow

### Tmux

- Plugin manager (TPM) with sensible defaults
- Theme: tmux-power (gold theme)
- Session resurrection support
- Optimized for image previews in yazi

### Zsh

- Prezto framework with PowerLevel10k theme
- Custom aliases and functions
- Enhanced history search
- Automatic editor variable setup (prefers nvim over vim)

## Manual Setup (if needed)

If you prefer manual installation or need to troubleshoot:

<details>
<summary>Manual Neovim Setup</summary>

```bash
# Clean existing config
rm -rf ~/.config/nvim ~/.local/{state,share,cache}/nvim

# Link configuration
ln -fs ~/git/dotfiles/nvim ~/.config/nvim

# Install plugins
nvim --headless -c "Lazy! sync" -c "qa"
nvim --headless -c "MasonInstallAll" -c "qa"
```

</details>

<details>
<summary>Manual Vim Setup</summary>

```bash
git clone https://github.com/cocopon/iceberg.vim.git ~/git/iceberg.vim
mkdir -p ~/.vim/colors
ln -fs ~/git/iceberg.vim/colors/iceberg.vim ~/.vim/colors/iceberg.vim
ln -fs ~/git/dotfiles/.vimrc ~/.vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim +'PlugInstall --sync' +qa
```

</details>

<details>
<summary>Manual Tmux Setup</summary>

```bash
ln -fs ~/git/dotfiles/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
tmux start-server
tmux new-session -d
tmux source ~/.tmux.conf
~/.tmux/plugins/tpm/scripts/install_plugins.sh
tmux kill-server
```

</details>

## Architecture

```
dotfiles/
├── install.sh              # Automated installation script
├── nvim/                   # Neovim configuration (LazyVim)
├── yazi/                   # Yazi file manager configuration
├── ghostty/                # Ghostty terminal configuration  
├── .vimrc                  # Vim configuration
├── .tmux.conf             # Tmux configuration
├── .zshrc                 # Zsh configuration
├── .gitconfig             # Git configuration
├── .aliases               # Shell aliases
├── .p10k.zsh             # PowerLevel10k theme
└── .zprezto/             # Prezto framework customizations
```

## Updating

- **Yazi plugins:** `ya pkg upgrade`
- **Neovim plugins:** `:Lazy sync` in nvim
- **Tmux plugins:** `<prefix>U` in tmux
- **Vim plugins:** `:PlugUpdate` in vim

## Links

- [Fastfetch](https://github.com/fastfetch-cli/fastfetch/releases) - System information tool
- [LazyVim](https://www.lazyvim.org/) - Neovim configuration framework  
- [Yazi](https://yazi-rs.github.io/) - Terminal file manager
- [Prezto](https://github.com/sorin-ionescu/prezto) - Zsh configuration framework
