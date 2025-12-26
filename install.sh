#!/bin/bash

sudo pacman -S socat initify-tools gtop cava


mkdir -p ~/.config/hypr
cp -rf .config/hypr/* ~/.config/hypr/

mkdir -p ~/.config/waybar
cp -rf .config/waybar/* ~/.config/waybar/

mkdir -p ~/.local/share/bin
cp -rf .local/share/bin/* ~/.local/share/bin/

mkdir -p ~/Pictures/Profiles
if [ -d "Profile" ]; then
    cp -rf Profile/* ~/Pictures/Profile/
fi

cp rei.conf ~/Git/SilentSDDM/configs/

chmod +x ~/.config/hypr/scripts/*.sh 2>/dev/null
chmod +x ~/.local/share/bin/*.sh 2>/dev/null



