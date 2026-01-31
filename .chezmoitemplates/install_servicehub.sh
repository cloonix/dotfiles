#!/usr/bin/env bash
# Wrapper script to fix service-hub installation
# The upstream install script uses invalid egg fragment syntax

set -euo pipefail

# Use the correct pipx install syntax
if command -v pipx >/dev/null 2>&1; then
    if pipx list 2>/dev/null | grep -q "service-hub"; then
        # Try upgrade first
        if ! pipx upgrade --force service-hub 2>/dev/null; then
            # If upgrade fails, uninstall and reinstall with correct syntax
            pipx uninstall service-hub 2>/dev/null || true
            pipx install --force "service-hub[cli] @ git+https://github.com/cloonix/service-hub.git"
        fi
    else
        pipx install --force "service-hub[cli] @ git+https://github.com/cloonix/service-hub.git"
    fi
    exit 0
else
    echo "pipx not found, cannot install service-hub"
    exit 1
fi
