#!/bin/bash

print_colored() {
        COLORED=$(echo "$1" | sed -E 's|^([^/]+)|\x1b[32m\1\x1b[0m|g')
        echo "$COLORED"
        echo "Number of packages to upgrade: $(echo "$1" | wc -l)"
}

# strict mode
set -euo pipefail

sudo apt update
STATUS=$?

if [ $STATUS -ne 0 ]; then
    echo "Error: update failed with $STATUS"
    exit 1
fi

if [ -n "${1:-}" ]; then
    UPGRADES=$(apt list --upgradable 2>/dev/null | grep -v "^Listing..." | grep -iE -- "$1[^\/]*\/" || true)

    if [ -z "$UPGRADES" ]; then
        echo "Nothing found"
    else
        print_colored "$UPGRADES"
    fi
else
    UPGRADES=$(apt list --upgradable 2>/dev/null | grep -v "^Listing..." || true)

    if [ -z "$UPGRADES" ]; then
        echo "Your system is up to date"
    else
        print_colored "$UPGRADES"
    fi
fi
