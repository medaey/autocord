#!/bin/bash
vars() {
violet="\033[38;5;63m"
blue="\033[0;34m"
red="\033[0;31m"
orange="\033[0;33m"
green="\033[0;32m"
nc="\033[0m"
DISCORD_UPDATE_URL="https://discord.com/api/updates/stable?platform=linux"
JSON_DATA=$(curl -s "$DISCORD_UPDATE_URL")
JSON_SETTINGS=$HOME/.config/discord/settings.json
LATEST_VERSION=$(echo "$JSON_DATA" | jq -r '.name')
DEB_URL="https://discord.com/api/download/stable?platform=linux&format=deb"
TAR_URL="https://discord.com/api/download/stable?platform=linux&format=tar.gz"
INSTALL_DIR="$HOME/.local/opt/discord"
BIN_DIR="$HOME/.local/bin"
TEMP_DIR=$(mktemp -d)
DESKTOP_FILE="$HOME/.local/share/applications/discord.desktop"
}

check_depends() {
deps=("jq" "curl" "tar" "gzip" "pv" "notify-send")
for _f in ${deps[@]} ; do
    if ! command -v /usr/bin/${_f} > /dev/null ; then
        echo -e "${red}Dépendances manquantes :${nc} ${_f}"
        missdep="1"
    fi
done

if [[ ${missdep} == "1" ]]; then
    echo -e "${red}Veuillez installer les dépendances manquantes et relancer le script${nc}"
    exit 1
fi

}

print_info() {
if [[ -n "$LATEST_VERSION" ]]; then
    echo -e "Version actuelle installée  : ${INSTALLED_VER}"
    echo -e "Dernière version de Discord : ${LATEST_VERSION}"
    echo -e "URL du fichier .deb    : ${DEB_URL}"
    echo -e "URL du fichier .tar.gz : ${TAR_URL}"
fi
}

local_Skip_host_update() {
local SEARCH_STRING='"SKIP_HOST_UPDATE": true,'
if [[ -f "${JSON_SETTINGS}" ]]; then
    if grep -q "${SEARCH_STRING}" "${JSON_SETTINGS}"; then
        sed -i '1a\  "SKIP_HOST_UPDATE": true,' "${JSON_SETTINGS}"
    fi
else
    mkdir "${HOME}/.config/discord/"
    echo '{
  "SKIP_HOST_UPDATE": true,
  "IS_MAXIMIZED": false,
  "IS_MINIMIZED": false,
  "WINDOW_BOUNDS": {
    "x": 235,
    "y": 327,
    "width": 2199,
    "height": 923
  },
  "OPEN_ON_STARTUP": false,
  "chromiumSwitches": {}
}' > "${JSON_SETTINGS}"
fi
}

local_install() {
echo -e "Téléchargement de Discord..."
curl -L "${TAR_URL}" --progress-bar -o "${TEMP_DIR}"/discord.tar.gz
echo -e "Extraction de Discord..."
#tar -xzf "${TEMP_DIR}/discord.tar.gz" -C "${TEMP_DIR}"
pv "${TEMP_DIR}/discord.tar.gz" | tar -xzf - -C "${TEMP_DIR}"

if [[ -d "${INSTALL_DIR}" ]]; then
    rm -r "${INSTALL_DIR}"
fi
mkdir -p "${INSTALL_DIR}"
mv "${TEMP_DIR}/Discord"/* "${INSTALL_DIR}"

# Créer un symlink pour l'exécutable

echo -e "Création du lien symbolique pour l'exécutable..."
if [[ ! -f "${BIN_DIR}/discord" ]]; then
    mkdir -p "${BIN_DIR}"
    ln -sf "${INSTALL_DIR}/Discord" "${BIN_DIR}/discord"
fi

# Créer un fichier .desktop pour l'intégration avec l'environnement de bureau
if [[ ! -f "${DESKTOP_FILE}" ]]; then
mkdir -p "${HOME}/.local/share/applications"
echo -e "Création du fichier .desktop..."
cat > "${DESKTOP_FILE}" <<EOF
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=${BIN_DIR}/discord
Icon=${INSTALL_DIR}/discord.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
Path=${HOME}/.local/bin
EOF

# Ajouter les permissions nécessaires au fichier .desktop
chmod +x "${DESKTOP_FILE}"
fi

# Nettoyer les fichiers temporaires
rm -rf "${TEMP_DIR}"

# Afficher un message de succès
echo -e "Discord a été installé avec succès dans l'espace utilisateur"
. "${HOME}/.bashrc"
}

local_uninstall() {
echo -e "Désinstallation de Discord et Autocord..."
rm "${BIN_DIR}"/discord
rm "${BIN_DIR}"/autocord
rm -r "${INSTALL_DIR}"
rm "${DESKTOP_FILE}"
}

check_version() {
if [[ -f "${BIN_DIR}/discord" ]]; then
    JSON_BUILD_INFO="${HOME}/.local/opt/discord/resources/build_info.json"
    INSTALLED_VER=$(jq -r '.version' "$JSON_BUILD_INFO")
    if [[ "${INSTALLED_VER}" != "${LATEST_VERSION}" ]]; then
        print_info
    else
        echo -e "Discord est déjà à jour !"
        if command -v /usr/bin/notify-send > /dev/null ; then
            notify-send --app-name "AUTOcord" "Discord est déjà à jour !"
        fi
        exit 0
    fi
fi
}

check_internet() {
    if ping -c 1 8.8.8.8 &> /dev/null; then
        return 0
    else
        return 1
    fi
}

check_root() {
if [[ $EUID -eq 0 ]]; then
    echo -e "${red}NE PAS LANCER LE SCRIPT EN TANT QUE ROOT${nc}"
    exit 1
fi
}

title() {
echo -e "${violet}
    ___   __  ____________                      __
   /   | / / / /_  __/ __ \_________  _________/ /
  / /| |/ / / / / / / / / / ___/ __ \/ ___/ __  /
 / ___ / /_/ / / / / /_/ / /__/ /_/ / /  / /_/ /
/_/  |_\____/ /_/  \____/\___/\____/_/   \____/
${nc}"
}

help() {
echo -e "
OPTIONS :

    install     : Installe discord en userspace
    uninstall   : Désinstalle discord et autocord
"
}

test_internet() {
local MAX_TIME=600
local START_TIME=$(date +%s)

while ! check_internet; do
    ELAPSED_TIME=$(( $(date +%s) - START_TIME ))

    if [ $ELAPSED_TIME -ge $MAX_TIME ]; then
        echo "Temps écoulé de 10 minutes sans connexion Internet. Arrêt du script."
        exit 1
    fi
    echo "Pas de connexion Internet. Nouvelle tentative dans 5 secondes..."
    sleep 30
done
}

case "${1}" in
    install)
        # Vérifications et initialisation
        test_internet
        check_depends
        vars
        title
        check_root
        check_version

        # Notification de début d'installation
        if command -v /usr/bin/notify-send > /dev/null; then
            notify-send --app-name "AUTOcord" "Discord ${LATEST_VERSION} disponible ! Installation en cours..."
        fi

        # Installation
        local_install
        local_Skip_host_update

        # Notification de fin d'installation
        if command -v /usr/bin/notify-send > /dev/null; then
            notify-send --app-name "AUTOcord" "Installation de Discord ${LATEST_VERSION} terminée !"
        fi

        echo -e "Installation Terminée"
        ;;

    uninstall)
        # Désinstallation
        vars
        title
        local_uninstall
        echo -e "Désinstallation Terminée"
        ;;

    --help | *)
        # Affichage de l'aide
        check_depends
        vars
        title
        print_info
        help
        ;;
esac
