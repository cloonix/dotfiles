#!/bin/zsh
# Shared helper functions for chezmoi scripts

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
error() { echo -e "${RED}❌${NC} $1"; }
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

# Create symlink with backup
link_file() {
    local src="$1" dest="$2"
    [[ -e "$dest" && ! -L "$dest" ]] && mv "$dest" "${dest}.backup.$(date +%s)" 2>/dev/null
    mkdir -p "$(dirname "$dest")" 2>/dev/null || return 1
    rm -rf "$dest" 2>/dev/null || return 1
    ln -fs "$src" "$dest" 2>/dev/null || return 1
    return 0
}
