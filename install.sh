#!/bin/bash
violet="\033[38;5;63m"
blue="\033[0;34m"
red="\033[0;31m"
orange="\033[0;33m"
green="\033[0;32m"
nc="\033[0m"

title() {
echo -e "${violet}
    ___   __  ____________                      __
   /   | / / / /_  __/ __ \_________  _________/ /
  / /| |/ / / / / / / / / / ___/ __ \/ ___/ __  /
 / ___ / /_/ / / / / /_/ / /__/ /_/ / /  / /_/ /
/_/  |_\____/ /_/  \____/\___/\____/_/   \____/
${nc}"
}

install() {
# Add ~/.local/bin to PATH permanently if it's not already there
if ! grep -q "$HOME/.local/bin" <<< "$PATH"; then
    if [ -n "$BASH_VERSION" ]; then
        echo -e 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        echo -e 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.zshrc"
    fi
fi

echo -e "${blue}Installation du binaire${nc}"
if [[ ! -d "${HOME}"/.local/bin ]]; then
    mkdir -p "${HOME}"/.local/bin
fi
cp "autocord.sh" "${HOME}"/.local/bin/autocord
chmod +x "${HOME}"/.local/bin/autocord

echo -e "${blue}Installation du service de mise à jour${nc}"
if [[ ! -d "${HOME}"/.config/autostart ]]; then
    mkdir -p "${HOME}"/.config/autostart
fi
cp "autocord-autostart.desktop" "${HOME}"/.config/autostart/autocord-autostart.desktop

echo -e "${blue}Mise à jour du path${nc}"
if [ -n "$BASH_VERSION" ]; then
    . "${HOME}/.bashrc"
elif [ -n "$ZSH_VERSION" ]; then
    . "${HOME}/.zshrc"
fi

echo -e "${blue}Installation de Discord via Autocord${nc}"
bash "$HOME"/.local/bin/autocord install
echo -e "${orange}Si vous avez des emoji manquantes sur votre DE, copiez le fichier fontconfig/local.conf dans ~/.config/fontconfig et déconnectez vous${nc}"
}

title
install
