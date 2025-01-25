#!/bin/bash
# Prepare environment for Autocord
# - Ensure ~/.local/bin exists and is in the PATH
# - Copy necessary files to appropriate locations
# - Set executable permissions for the script
# - Reload shell configuration and execute installation

# Create ~/.local/bin if it doesn't exist and add it to PATH
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:$PATH"
export PATH="$(echo $PATH)" # Refresh PATH to avoid duplicates

# Copy scripts and configuration files
cp autocord.sh "${HOME}"/.local/bin/autocord
cp autocord-autostart.desktop "${HOME}"/.config/autostart/autocord-autostart.desktop

# Make the main script executable
chmod +x "${HOME}"/.local/bin/autocord

# Reload shell configuration to apply changes
. "${HOME}"/.bashrc

# Run the Autocord installation process
autocord install