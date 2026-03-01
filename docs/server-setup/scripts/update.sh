#!/bin/bash
echo "Checking for & installing updates..."
sudo apt update && sudo apt upgrade -y
if [ -f /usr/local/bin/oh-my-posh ]; then
    read -n1 -r -p "Update Oh My Posh? [Y/n] " key
        if [ "${key,,}" == "n" ]; then
            echo
            echo "Oh My Posh update cancelled"
            exit
            else
            echo
            echo "Updating Oh My Posh..."
            wget https://ohmyposh.dev/install.sh -O omp-install.sh
            chmod +x omp-install.sh
            sudo ./omp-install.sh
            rm omp-install.sh
        fi
fi
if [ -d "/home/alan/containers/hawser" ]; then
    echo "Updating Hawser"
    cd /home/alan/containers/hawser
    docker compose pull  && docker compose up -d
fi