#!/bin/bash

# 1. Konfigurasi Hyprland
mkdir -p ~/.config/hypr
cp -rf .config/hypr/* ~/.config/hypr/

# 2. Konfigurasi Waybar
mkdir -p ~/.config/waybar
cp -rf .config/waybar/* ~/.config/waybar/

# 3. Script Local Bin
mkdir -p ~/.local/share/bin
cp -rf .local/share/bin/* ~/.local/share/bin/

# 4. Memberikan izin eksekusi (chmod +x)
chmod +x ~/.config/hypr/scripts/*.sh
chmod +x ~/.local/share/bin/*.sh
