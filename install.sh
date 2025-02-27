#!/bin/bash
violet="\033[38;5;63m"
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
    echo -e "${violet}Installation du binaire${nc}"
    if [[ ! -d "${HOME}"/.local/bin ]]; then
        mkdir -p "${HOME}"/.local/bin
    fi
    cp autocord.sh "${HOME}"/.local/bin/autocord
    chmod +x "${HOME}"/.local/bin/autocord

    echo -e "${violet}Installation du service de mise à jour${nc}"
    if [[ ! -d "${HOME}"/.config/autostart ]]; then
        mkdir -p "${HOME}"/.config/autostart/
    fi
    cp autocord-autostart.desktop "${HOME}"/.config/autostart/autocord-autostart.desktop

    echo -e "${violet}Mise à jour du path${nc}"
    . "${HOME}"/.bashrc

    echo -e "${violet}Installation de Discord via Autocord${nc}"
    bash "$HOME"/.local/bin/autocord install
}

title
install