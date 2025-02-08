#!/bin/bash

# Uncomment en_GB.UTF-8 for inclusion in generation
sed -i 's/^# *\(en_GB.UTF-8\)/\1/' /etc/locale.gen

# Generate locale
locale-gen

# Export env vars
echo "export LC_ALL=en_GB.UTF-8" >> ~/.bashrc
echo "export LANG=en_GB.UTF-8" >> ~/.bashrc
echo "export LANGUAGE=en_GB.UTF-8" >> ~/.bashrc

# Reload bashrc
source ~/.bashrc