#!/bin/bash
# Recreate mkdocs containers for local development
echo "Stopping existing containers:"
docker stop mkdocs-linuxnotes mkdocs-ekora
echo
echo "Removing existing containers:"
docker rm mkdocs-linuxnotes mkdocs-ekora
echo
echo "Creating new containers:"
docker run -d --volume=/home/alan/repositories/linux-notes:/docs --name mkdocs-linuxnotes -p5010:8000 --restart=always custom/mkdocs-material
docker run -d --volume=/home/alan/repositories/EKORA-documentation:/docs --name mkdocs-ekora -p5000:8000 --restart=always custom/mkdocs-material