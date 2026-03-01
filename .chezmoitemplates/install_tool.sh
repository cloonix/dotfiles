# Shared helper for installing custom curl-based tools
# Usage: install_tool <name> <url> <check_command> <always_run>
#
# Arguments:
#   name          - Display name (e.g., "opencode")
#   url           - Install script URL
#   check_command - Command to check if installed (e.g., "opencode")
#   always_run    - "true" to always run, "false" to only run if missing

install_tool() {
    local name="$1"
    local url="$2"
    local check_cmd="$3"
    local always_run="${4:-false}"

    if [[ "$always_run" == "true" ]]; then
        progress "Upgrading $name"
    elif ! command -v "$check_cmd" >/dev/null 2>&1; then
        progress "Installing $name"
    else
        success "$name already installed"
        return 0
    fi

    local tmp_output
    tmp_output=$(mktemp)

    if /bin/bash -c "$(curl -fsSL "$url")" >"$tmp_output" 2>&1; then
        finish
        rm -f "$tmp_output"
        return 0
    else
        local exit_code=$?
        if grep -q "Failed to fetch version\|rate limit\|API rate" "$tmp_output" 2>/dev/null; then
            rm -f "$tmp_output"
            warn "$name: skipped (rate limited)"
            return 0
        fi
        failed
        if [ -s "$tmp_output" ]; then
            printf "\n"
            tail -10 "$tmp_output" | sed 's/^/    /'
        fi
        rm -f "$tmp_output"
        return $exit_code
    fi
}
