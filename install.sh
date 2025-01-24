#!/bin/bash
cp autocord.sh "${HOME}"/.local/bin/autocord
cp autocord-autostart.desktop "${HOME}"/.config/autostart/autocord-autostart.desktop
chmod +x "${HOME}"/.local/bin/autocord
. "${HOME}"/.bashrc

autocord install
