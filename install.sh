#!/bin/bash
cp autocord.sh "${HOME}"/.local/bin/autocord
chmod +x "${HOME}"/.local/bin/autocord
. "${HOME}"/.bashrc

autocord install
