# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Output helpers
log()     { printf "${BLUE}::${NC} %s\n" "$1"; }
success() { printf "${GREEN}✓${NC} %s\n" "$1"; }
warn()    { printf "${YELLOW}⚠${NC} %s\n" "$1"; }
error()   { printf "${RED}✗${NC} %s\n" "$1"; }
info()    { printf "${BLUE}ℹ${NC} %s\n" "$1"; }

section() { printf "\n${BOLD}%s${NC}\n" "$1"; }

# Progress indicators
progress() { printf "${BLUE}::${NC} %s... " "$1"; }
finish()   { printf "${GREEN}done${NC}\n"; }
failed()   { printf "${RED}failed${NC}\n"; }
