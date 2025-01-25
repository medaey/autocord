#!/bin/bash
# Prepare environment for Autocord
# - Ensure ~/.local/bin exists and is in the PATH
# - Copy necessary files to appropriate locations
# - Set executable permissions for the script
# - Reload shell configuration and execute installation

# Create ~/.local/bin if it doesn't exist
mkdir -p "${HOME}/.local/bin"

# Add ~/.local/bin to PATH permanently if it's not already there
if ! grep -q "$HOME/.local/bin" <<< "$PATH"; then
    if [ -n "$BASH_VERSION" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
    fi
fi

# Refresh PATH for the current session (if already open)
export PATH="${HOME}/.local/bin:$PATH"

# Copy scripts and configuration files
cp autocord.sh "${HOME}"/.local/bin/autocord
cp autocord-autostart.desktop "${HOME}"/.config/autostart/autocord-autostart.desktop

# Make the main script executable
chmod +x "${HOME}"/.local/bin/autocord

# Reload shell configuration to apply changes
if [ -n "$BASH_VERSION" ]; then
    . "${HOME}/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    . "${HOME}/.zshrc"
fi

# Run the Autocord installation process
autocord install
