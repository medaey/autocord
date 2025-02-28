#!/bin/bash
vars() {
    # Couleurs - préfixe 'CLR_' pour plus de clarté
    readonly CLR_VIOLET="\033[38;5;63m"
    readonly CLR_BLUE="\033[0;34m"
    readonly CLR_RED="\033[0;31m"
    readonly CLR_ORANGE="\033[0;33m"
    readonly CLR_GREEN="\033[0;32m"
    readonly CLR_RESET="\033[0m"

    # URLs - préfixe 'URL_' pour les endpoints
    readonly URL_DISCORD_API="https://discord.com/api"
    readonly URL_DISCORD_UPDATE="${URL_DISCORD_API}/updates/stable?platform=linux"
    readonly URL_DISCORD_DEB="${URL_DISCORD_API}/download/stable?platform=linux&format=deb"
    readonly URL_DISCORD_TAR="${URL_DISCORD_API}/download/stable?platform=linux&format=tar.gz"

    # Chemins - préfixe 'PATH_' pour les dossiers
    readonly PATH_CONFIG="${HOME}/.config/discord"
    readonly PATH_INSTALL="${HOME}/.local/opt/discord"
    readonly PATH_BIN="${HOME}/.local/bin"
    readonly PATH_DESKTOP="${HOME}/.local/share/applications/discord.desktop"
    readonly PATH_SETTINGS="${PATH_CONFIG}/settings.json"
    readonly PATH_TEMP="$(mktemp -d)"

    # Versions
    readonly JSON_DATA=$(curl -s "${URL_DISCORD_UPDATE}")
    readonly VERSION_LATEST=$(echo "${JSON_DATA}" | jq -r '.name')
}

check_depends() {
    deps=("jq" "curl" "tar" "gzip" "pv" "notify-send")
    for _f in ${deps[@]} ; do
        if ! command -v /usr/bin/${_f} > /dev/null ; then
            echo -e "${CLR_RED}Dépendances manquantes :${CLR_RESET} ${_f}"
            missdep="1"
        fi
    done

    if [[ ${missdep} == "1" ]]; then
        echo -e "${CLR_RED}Veuillez installer les dépendances manquantes et relancer le script${CLR_RESET}"
        exit 1
    fi
}

local_Skip_host_update() {
    local SEARCH_STRING='"SKIP_HOST_UPDATE": true,'
    if [[ -f "${PATH_SETTINGS}" ]]; then
        if grep -q "${SEARCH_STRING}" "${PATH_SETTINGS}"; then
            sed -i '1a\  "SKIP_HOST_UPDATE": true,' "${PATH_SETTINGS}"
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
    }' > "${PATH_SETTINGS}"
    fi
}

local_install() {
    echo -e "Téléchargement de Discord..."
    curl -L "${URL_DISCORD_TAR}" --progress-bar -o "${PATH_TEMP}"/discord.tar.gz
    echo -e "Extraction de Discord..."
    #tar -xzf "${TEMP_DIR}/discord.tar.gz" -C "${TEMP_DIR}"
    pv "${PATH_TEMP}/discord.tar.gz" | tar -xzf - -C "${PATH_TEMP}"

    if [[ -d "${PATH_INSTALL}" ]]; then
        rm -r "${PATH_INSTALL}"
    fi
    mkdir -p "${PATH_INSTALL}"
    mv "${PATH_TEMP}/Discord"/* "${PATH_INSTALL}"

    # Créer un symlink pour l'exécutable
    echo -e "Création du lien symbolique pour l'exécutable..."
    if [[ ! -f "${PATH_BIN}/discord" ]]; then
        mkdir -p "${PATH_BIN}"
        ln -sf "${PATH_INSTALL}/Discord" "${PATH_BIN}/discord"
    fi

    # Créer un fichier .desktop pour l'intégration avec l'environnement de bureau
    if [[ ! -f "${PATH_DESKTOP}" ]]; then
    mkdir -p "${HOME}/.local/share/applications"
    echo -e "Création du fichier .desktop..."
cat > "${PATH_DESKTOP}" <<EOF
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=${PATH_BIN}/discord
Icon=${PATH_INSTALL}/discord.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
Path=${HOME}/.local/bin
EOF

    # Ajouter les permissions nécessaires au fichier .desktop
    chmod +x "${PATH_DESKTOP}"
    fi

    # Nettoyer les fichiers temporaires
    rm -rf "${PATH_TEMP}"

    # Afficher un message de succès
    echo -e "Discord a été installé avec succès dans l'espace utilisateur"
    . "${HOME}/.bashrc"
}

local_uninstall() {
    echo -e "Désinstallation de Discord et Autocord..."
    rm "${PATH_BIN}"/discord
    rm "${PATH_BIN}"/autocord
    rm -r "${PATH_INSTALL}"
    rm "${PATH_DESKTOP}"
}

check_version() {
    if [[ -f "${PATH_BIN}/discord" ]]; then
        if [[ -f "${HOME}/.local/opt/discord/resources/build_info.json" ]]; then
            INSTALLED_VER=$(jq -r '.version // empty' "${HOME}/.local/opt/discord/resources/build_info.json")
            if [[ -z "$INSTALLED_VER" ]]; then
                echo -e "❌ Impossible de récupérer la version installée."
            elif [[ "${INSTALLED_VER}" != "${VERSION_LATEST}" ]]; then
                print_info
            else
                echo -e "✅ Discord est déja à jour !"
                exit 0
            fi
        else
            echo -e "❌ Fichier build_info.json introuvable !"
        fi
    fi
}

print_info() {
    local INSTALLED_VER=$(jq -r '.version // empty' "${HOME}/.local/opt/discord/resources/build_info.json")
    if [[ -n "$VERSION_LATEST" ]]; then
        echo -e "🖥️  Version actuelle installée  : ${INSTALLED_VER:-❌ Non installé}"
        echo -e "✨ Dernière version de Discord : ${VERSION_LATEST}"
        echo -e "📥 URL du fichier .deb    : ${URL_DISCORD_DEB}"
        echo -e "📦 URL du fichier .tar.gz : ${URL_DISCORD_TAR}"
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
        echo -e "${CLR_RED}NE PAS LANCER LE SCRIPT EN TANT QUE ROOT${CLR_RESET}"
        exit 1
    fi
}

title() {
    echo -e "${CLR_VIOLET}
        ___   __  ____________                      __
       /   | / / / /_  __/ __ \_________  _________/ /
      / /| |/ / / / / / / / / ___/ __ \/ ___/ __  /
     / ___ / /_/ / / / / /_/ / /__/ /_/ / /  / /_/ /
    /_/  |_\____/ /_/  \____/\___/\____/_/   \____/
    ${CLR_RESET}"
}

help() {
    echo -e "
        OPTIONS :

          install     : Installe Discord en userspace
          uninstall   : Désinstalle Discord et AUTOcord
          update      : Vérifie si une nouvelle version de Discord est disponible
          --help      : Affiche cette aide"
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

# Fonction pour gérer l'installation
install_discord() {
    # Vérifications préliminaires
    run_pre_install_checks
    
    # Notification de début d'installation
    send_notification "Discord ${VERSION_LATEST} disponible ! Installation en cours..."
    
    # Installation principale
    download_and_extract_discord
    setup_discord_directories
    create_symlinks_and_desktop_file
    local_Skip_host_update
    
    # Notification de fin
    send_notification "Installation de Discord ${VERSION_LATEST} terminée !"
    echo -e "Installation Terminée"
}

# Fonctions auxiliaires d'installation
run_pre_install_checks() {
    test_internet
    check_depends
    vars
    title
    check_root
    check_version
}

download_and_extract_discord() {
    echo -e "Téléchargement de Discord..."
    curl -L "${URL_DISCORD_TAR}" --progress-bar -o "${PATH_TEMP}"/discord.tar.gz
    echo -e "Extraction de Discord..."
    pv "${PATH_TEMP}/discord.tar.gz" | tar -xzf - -C "${PATH_TEMP}"
}

setup_discord_directories() {
    if [[ -d "${PATH_INSTALL}" ]]; then
        rm -r "${PATH_INSTALL}"
    fi
    mkdir -p "${PATH_INSTALL}"
    mv "${PATH_TEMP}/Discord"/* "${PATH_INSTALL}"
}

create_symlinks_and_desktop_file() {
    # Création du lien symbolique
    echo -e "Création du lien symbolique pour l'exécutable..."
    if [[ ! -f "${PATH_BIN}/discord" ]]; then
        mkdir -p "${PATH_BIN}"
        ln -sf "${PATH_INSTALL}/Discord" "${PATH_BIN}/discord"
    fi

    create_desktop_file
    rm -rf "${PATH_TEMP}"
}

create_desktop_file() {
    if [[ ! -f "${PATH_DESKTOP}" ]]; then
        mkdir -p "${HOME}/.local/share/applications"
        echo -e "Création du fichier .desktop..."
        generate_desktop_file_content > "${PATH_DESKTOP}"
        chmod +x "${PATH_DESKTOP}"
    fi
}

generate_desktop_file_content() {
    cat <<EOF
[Desktop Entry]
Name=Discord
StartupWMClass=discord
Comment=All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.
GenericName=Internet Messenger
Exec=${PATH_BIN}/discord
Icon=${PATH_INSTALL}/discord.png
Terminal=false
Type=Application
Categories=Network;InstantMessaging;
Path=${HOME}/.local/bin
EOF
}

send_notification() {
    local message="$1"
    if command -v /usr/bin/notify-send > /dev/null; then
        notify-send --app-name "AUTOcord" "$message"
    fi
}

case "${1}" in
    install)
        install_discord
        ;;
    uninstall)
        # Désinstallation
        vars
        title
        local_uninstall
        echo -e "Désinstallation Terminée"
        ;;
    update)
        # Vérification de la version
        check_version
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
