#!/bin/bash

echo "🚀 Starting Widgets..."
sleep 0.5

# ==============================================================================
# 1. FASE PEMBERSIHAN (CLEANUP)
# ==============================================================================
pkill -f "pokemon-colorscripts" || true
pkill -f "tty-clock" || true
# Matikan kedua monitor agar bersih saat switch
pkill -f "gtop" || true
pkill -f "btop" || true
pkill -f "cava" || true
pkill -f "fastfetch" || true
pkill -f "uptime.sh" || true
pkill -f "unimatrix" || true
pkill -f "cmatrix" || true

# Tutup jendela via Hyprland
hyprctl clients -j | jq -r '.[] | select(.class | test(".*-widget$")) | .address' | while read -r addr; do
    hyprctl dispatch closewindow "address:$addr"
done

sleep 0.5

# ==============================================================================
# 2. FASE PELUNCURAN (LAUNCH)
# ==============================================================================

launch_widget() {
  local class=$1
  local title=$2
  local command=$3

  echo "Launching: $title ($class)"
  # Opacity 0.8 diterapkan ke semua widget
  kitty --class "$class" --title "$title" -o font_size=8.5 -o background_opacity=0.6 -e bash -c "$command" &
}

# --- Jalankan Widget ---

# Clock
launch_widget "clock-widget" "Clock" "tty-clock -c -C 4 -f '%A, %B %d' -b"
sleep 0.1

# System Monitor
# [PILIHAN USER]
# Baris gtop dimatikan (di-comment) sesuai request:
launch_widget "system-widget" "System Monitor" "gtop"

# Baris btop diaktifkan (menggunakan class yang sama 'system-widget' agar posisi tetap):
#launch_widget "system-widget" "System Monitor" "btop --utf-force"
sleep 0.1

# Pokemon
launch_widget "pokemon-widget" "Pokemon" "while true; do clear; pokemon-colorscripts --no-title -n charizard; sleep 360; done"
sleep 0.1

# System Info
# Gunakan 'sleep infinity' untuk menahan window agar tidak menutup
launch_widget "info-widget" "System Info" "fastfetch -l arch2; sleep infinity"
sleep 0.1

# Matrix (Pengganti Uptime - Posisi Tengah Bawah)
echo "Launching: Matrix (stopwatch-widget)"
kitty --class "stopwatch-widget" --title "Matrix" -o font_size=8.5 -o background_opacity=0.6 -e bash -c "unimatrix -n -s 96 -c green" &

echo "✅ All widget processes initiated."
