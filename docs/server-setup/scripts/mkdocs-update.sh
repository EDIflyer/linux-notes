#!/bin/bash
echo "Current version:"
docker exec -it mkdocs-live pip3 show mkdocs-material
echo "----------------"
echo "Rebuilding from dockerfile:"
sudo docker build --pull --tag="custom/mkdocs-material" --file="mkdocs.dockerfile" .
echo "----------------"
read -n 1 -p "Press any key to continue once Portainer stack has been updated..."
echo "Updated version:"
docker exec -it mkdocs-live pip3 show mkdocs-material
echo "----------------"
echo "Script complete, remember to delete old mkdocs image in Portainer"