#!/bin/bash
echo "AJR btop installer"
echo "------------------"
if [ "$1" = "x64" ]; then 
    echo ">>> Command line x64 option selected"
    echo
    filename="btop-x86_64-linux-musl.tbz"
elif [ "$1" = "aarch64" ]; then 
    echo ">>> Command line aarch64 option selected"
    echo
    filename="btop-aarch64-linux-musl.tbz"
else
    echo "No architecture selected when running script, please select either x64 or aarch64."
    echo "  1. x64"
    echo "  2. aarch64"
    echo 
    read -p "Enter the number of the architecture you want to install: " architecture_number
    if [ "$architecture_number" = "1" ]; then
        echo ">>> x64 option selected"
        echo
        filename="btop-x86_64-linux-musl.tbz"
    elif [ "$architecture_number" = "2" ]; then
        echo ">>> aarch64 option selected"
        echo
        filename="btop-aarch64-linux-musl.tbz"
    else
        echo
        echo ">>> Invalid option selected - exiting."
        exit 1
    fi
fi
echo
echo ">>> Installing dependencies..."
sudo apt install -y bzip2 make
echo ">>> Fetching latest release of btop..."
curl -s https://api.github.com/repos/aristocratos/btop/releases/latest \
| grep ""$filename"" \
| cut -d : -f 2,3 \
| tr -d \" \
| wget -i -
echo ">>> Extracting and installing btop..."
tar -xjf "$filename"
cd btop
./install.sh
echo ">>> Cleaning up..."
cd ..
rm "$filename"
rm -rf btop
echo ">>> Installation complete."