#!/usr/bin/env bash
# ==============================================================================
# Dotfiles Bootstrap & Installation Script (GNU Stow)
# ==============================================================================

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${HOME}"

echo "=================================================="
echo "Installing dotfiles from: ${DOTFILES_DIR}"
echo "Target home directory:    ${TARGET_DIR}"
echo "=================================================="

# Check if GNU stow is installed
if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow is not found. Attempting to install via Homebrew or APT..."
    if command -v brew >/dev/null 2>&1; then
        brew install stow
    elif command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y stow
    else
        echo "Error: Please install GNU stow manually." >&2
        exit 1
    fi
fi

# Modules to stow
MODULES=(
    "bash"
    "vim"
    "neovim"
    "tmux"
    "git"
    "script"
)

cd "${DOTFILES_DIR}"

for module in "${MODULES[@]}"; do
    if [ -d "$module" ]; then
        echo "Linking module: $module ..."
        stow -v -R -t "${TARGET_DIR}" "$module"
    fi
done

echo "=================================================="
echo "Dotfiles installation completed successfully!"
echo "=================================================="
