# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# Output helpers
log()     { printf "${BLUE}::${NC} %s\n" "$1"; }
success() { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}⚠${NC} %s\n" "$1"; }
error()   { printf "  ${RED}✗${NC} %s\n" "$1"; }
info()    { printf "  ${DIM}·${NC} %s\n" "$1"; }
dim()     { printf "${DIM}%s${NC}\n" "$1"; }

section() {
  local title="$1"
  local width="${COLUMNS:-80}"
  local pad=$(( width - ${#title} - 5 ))
  [ "$pad" -lt 2 ] && pad=2
  local line
  line=$(printf '─%.0s' $(seq 1 "$pad"))
  printf "\n${BOLD}${BLUE}── %s ${NC}${DIM}%s${NC}\n" "$title" "$line"
}

# Progress indicators
progress() { printf "  ${BLUE}·${NC} %s... " "$1"; }
finish()   { printf "${GREEN}done${NC}\n"; }
failed()   { printf "${RED}failed${NC}\n"; }

# Ensure Homebrew is available in PATH
setup_brew_path() {
    if [ -f "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
}

# Run a command with a progress label — exits on failure
# Usage: run "label" cmd [args...]
run() {
    local label="$1"; shift
    progress "$label"
    if "$@" >/dev/null 2>&1; then finish; else failed; exit 1; fi
}

# Run a command with a progress label — warns but continues on failure
# Usage: try "label" cmd [args...]
try() {
    local label="$1"; shift
    progress "$label"
    if "$@" >/dev/null 2>&1; then finish; else failed; fi
}
