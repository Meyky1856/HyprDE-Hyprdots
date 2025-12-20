#!/bin/bash

# --- Path Config (v4.6) ---
export waybar_dir="${HOME}/.config/waybar"
export waybar_config="${waybar_dir}/config.jsonc"
export waybar_style="${waybar_dir}/style.css"

if [ ! -d "$waybar_dir" ]; then
    echo "❌ FATAL: Direktori Waybar yang diharapkan tidak ada di $waybar_dir"
    exit 1
fi
# --- End Config ---

# Pastikan inotify-tools terinstal
if ! command -v inotifywait > /dev/null; then
    echo "❌ FATAL: 'inotify-tools' tidak terinstal. Harap instal (sudo pacman -S inotify-tools) dan jalankan ulang."
    # Tampilkan error ini di Waybar jika bisa, atau di log
    exit 1
fi

sleep 0.5
echo "🚀 Starting Robust Waybar Manager (v5.0)..."

# --- Fungsi ---
hide_waybar() {
    if pgrep -x waybar > /dev/null; then
        pkill -x waybar
        echo "Waybar hidden (Killed)."
    fi
}

show_waybar() {
    if ! pgrep -x waybar > /dev/null; then
        if [ ! -f "$waybar_config" ] || [ ! -f "$waybar_style" ]; then
            echo "Config/Style tidak ditemukan. Menjalankan generator..."
            if command -v wbarconfgen.sh > /dev/null; then
                wbarconfgen.sh
                sleep 0.5 
            else
                echo "❌ FATAL: 'wbarconfgen.sh' tidak ditemukan di \$PATH."
                return 1 
            fi
        fi 
        
        waybar --config "$waybar_config" --style "$waybar_style" > /dev/null 2>&1 &
        echo "Waybar shown (Started with Hyprdots config)."
    fi
}

# --- 1. Penanganan Awal ---
echo "Resetting Waybar state..."
hide_waybar
sleep 0.1 

echo "Memindahkan fokus ke Workspace 2..."
hyprctl dispatch workspace 2
sleep 0.2 

echo "Forcing Waybar start for Workspace 2..."
show_waybar

# --- 2. Listener 1: Config/Style Change (inotify) ---
# Jalankan ini di background
(
    echo "🎧 Starting Config/Style listener (inotify)..."
    while true; do
        # Tunggu sampai file style ATAU config dimodifikasi
        # -q membuat ini senyap (tidak ada output ke log)
        inotifywait -q -e modify "$waybar_config" "$waybar_style"
        
        echo "Event: Config/Style file changed! (wbarconfgen.sh was run)"
        
        # Cek apakah Waybar SEDANG berjalan
        if pgrep -x waybar > /dev/null; then
            echo "Waybar is running. Restarting it to apply changes..."
            hide_waybar
            sleep 0.1
            show_waybar
        else
            echo "Waybar is not running (likely on WS1). Changes will apply on next show."
        fi
    done
) &  # <-- '&' penting untuk menjalankan di background

# --- 3. Listener 2: Workspace Change (socat) ---
# Jalankan ini di foreground (proses utama skrip)
echo "🎧 Starting Workspace Change listener (socat)..."

if [ -n "$XDG_RUNTIME_DIR" ]; then
    HYPR_DIR="$XDG_RUNTIME_DIR/hypr"
else
    HYPR_DIR="/tmp/hypr"
fi
if [ ! -d "$HYPR_DIR" ]; then
    HYPR_DIR="/tmp/hypr"
    if [ ! -d "$HYPR_DIR" ]; then
        echo "❌ FATAL: Direktori Hyprland tidak ditemukan."
        exit 1
    fi
fi
HYPR_INSTANCE_DIR=$(ls -t "$HYPR_DIR" | head -n 1)
SOCKET_PATH="$HYPR_DIR/$HYPR_INSTANCE_DIR/.socket2.sock"
if [ ! -S "$SOCKET_PATH" ]; then
     echo "❌ FATAL: Soket tidak ditemukan di $SOCKET_PATH"
     exit 1
fi

echo "✅ Found socket: $SOCKET_PATH"
socat - "UNIX-CONNECT:$SOCKET_PATH" | while read -r line; do
    if [[ "$line" == "workspace>>"* ]]; then
        ACTIVE_WS_ID=$(echo "$line" | cut -d'>' -f3)
        echo "Event: Switched to workspace $ACTIVE_WS_ID"
        
        if [ "$ACTIVE_WS_ID" -eq 1 ]; then
            hide_waybar
        else
            show_waybar
        fi
    fi
done
