#!/bin/bash

# 0. Cek apakah figlet terinstal
if ! command -v figlet &> /dev/null; then
    echo "Error: 'figlet' tidak terinstal."
    echo "Silakan instal: sudo pacman -S figlet"
    sleep 3600
    exit 1
fi

# 1. Sembunyikan kursor dan bersihkan layar sekali
tput civis
clear

# 2. Pastikan kursor muncul lagi saat skrip dihentikan
trap 'tput cnorm; clear' EXIT

# 3. Loop utama
while true; do
    # 3a. Baca total detik dari /proc/uptime (ambil angka pertama)
    read -r uptime_seconds _ < /proc/uptime

    # 3b. Konversi ke integer (hilangkan desimal)
    uptime_int=${uptime_seconds%.*}

    # 3c. Hitung jam, menit, dan detik
    hours=$((uptime_int / 3600))
    minutes=$(((uptime_int / 60) % 60))
    seconds=$((uptime_int % 60))

    # 3d. Format string waktu
    time_string=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)

    # 3e. Dapatkan ukuran terminal saat ini
    # 'shopt -s checkwinsize' memastikan $LINES dan $COLUMNS update
    shopt -s checkwinsize
    term_height=$LINES
    term_width=$COLUMNS

    # 3f. Buat teks ASCII art menggunakan figlet
    # -c : center (horizontal)
    # -w $term_width : sesuaikan lebar dengan terminal
    ascii_art=$(figlet -c -w "$term_width" -f 3x5 "$time_string")
    
    # 3g. Hitung tinggi dari ASCII art (berapa baris)
    art_height=$(echo "$ascii_art" | wc -l)

    # 3h. Hitung padding (jarak) atas untuk center vertikal
    # ((Total Tinggi Terminal - Tinggi Art) / 2)
    padding_top=$(((term_height - art_height) / 2))

    # 3i. Bersihkan layar dan pindahkan kursor
    # 'tput clear' lebih baik dari 'clear' karena lebih cepat
    tput clear

    # 3j. Cetak padding atas (baris kosong)
    # Gunakan loop untuk mencetak newline
    for ((i=0; i<padding_top; i++)); do
        echo
    done

    # 3k. Cetak ASCII art
    echo "$ascii_art"

    # 3l. Tunggu 1 detik sebelum update
    sleep 1
done
