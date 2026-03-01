# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'
readonly NC='\033[0m'

# ── Output helpers ────────────────────────────────────────────────────────────

# Section header: ── Name ──────────
section() {
    local title=" $1 "
    local width=50
    local left="──"
    local right
    right=$(printf '─%.0s' $(seq 1 $((width - ${#title} - ${#left}))))
    printf "\n${BOLD}${BLUE}%s%s%s${NC}\n" "$left" "$title" "$right"
}

# Step indicators
progress() { printf "  ${BLUE}·${NC} %-40s" "$1..."; }
finish()   { printf "${GREEN}done${NC}\n"; }
failed()   { printf "${RED}failed${NC}\n"; }

# Status lines
success() { printf "  ${GREEN}✓${NC} %s\n" "$1"; }
warn()    { printf "  ${YELLOW}⚠${NC} %s\n" "$1"; }
error()   { printf "  ${RED}✗${NC} %s\n" "$1"; }
info()    { printf "  ${DIM}·${NC} %s\n" "$1"; }

# Summary box for final output
# Usage: summary_box "Title" "line1" "line2" ...
summary_box() {
    local title="$1"; shift
    local width=50
    local border
    border=$(printf '─%.0s' $(seq 1 $width))
    printf "\n${BOLD}${CYAN}┌%s┐${NC}\n" "$border"
    printf "${BOLD}${CYAN}│${NC}  %-${width}s${BOLD}${CYAN}│${NC}\n" "$title"
    printf "${BOLD}${CYAN}├%s┤${NC}\n" "$border"
    for line in "$@"; do
        printf "${BOLD}${CYAN}│${NC}  %-${width}s${BOLD}${CYAN}│${NC}\n" "$line"
    done
    printf "${BOLD}${CYAN}└%s┘${NC}\n" "$border"
}

# ── Command runners ───────────────────────────────────────────────────────────

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
