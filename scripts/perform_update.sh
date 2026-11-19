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
    # Escape regex dots and convert '*' wildcard to '[^/]*'
    PATTERN=$(echo "$1" | sed 's/\./\\./g; s/\*/[^\/]*/g')

    UPGRADES=$(apt list --upgradable 2>/dev/null | grep -v "^Listing..." | grep -iE -- "^${PATTERN}/" || true)

    if [ -z "$UPGRADES" ]; then
        echo "No upgrades found for '$1'"
        exit 0
    fi

    print_colored "$UPGRADES"
    echo ""

    PKG_NAMES=$(echo "$UPGRADES" | cut -d'/' -f1)

    read -rp "Do you want to upgrade this package? [y/N] " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        sudo apt install --only-upgrade -y $PKG_NAMES
    else
        echo "Upgrade cancelled."
    fi
else
    UPGRADES=$(apt list --upgradable 2>/dev/null | grep -v "^Listing..." || true)

    if [ -z "$UPGRADES" ]; then
        echo "Your system is up to date"
        exit 0
    fi

    print_colored "$UPGRADES"
    echo ""

    read -rp "Do you want to upgrade these packages? [y/N] " CONFIRM
    if [[ "$CONFIRM" =~ ^[Yy]$ ]]; then
        sudo apt upgrade -y
    else
        echo "Upgrade cancelled."
    fi
fi

