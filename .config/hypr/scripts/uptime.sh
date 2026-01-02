#!/bin/bash

# --- KONFIGURASI UKURAN (ASPECT RATIO) ---
# Coba kombinasi ini untuk hasil berbeda:
# X=1, Y=1 : Normal (Kecil)
# X=2, Y=1 : Lebar (Wide)
# X=1, Y=2 : Tinggi (Tall) - Mirip jam dinding digital
# X=2, Y=2 : Besar (Big)
SCALE_X=1  # Ketebalan Horizontal
SCALE_Y=1  # Ketebalan Vertikal

COLOR_CLOCK="\e[1;37m"  # Putih Terang
RESET="\e[0m"
# -----------------------------------------

# 1. Setup
tput civis
clear
trap 'tput cnorm; echo -e "${RESET}"; clear' EXIT

# 2. Definisi Pola Angka (Grid 3x5)
get_base_row() {
    local char=$1
    local row=$2
    case $char in
        0) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "█ █"; [ $row -eq 3 ] && echo -n "█ █"; [ $row -eq 4 ] && echo -n "█ █"; [ $row -eq 5 ] && echo -n "███" ;;
        1) [ $row -eq 1 ] && echo -n "  █"; [ $row -eq 2 ] && echo -n "  █"; [ $row -eq 3 ] && echo -n "  █"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "  █" ;;
        2) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "  █"; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "█  "; [ $row -eq 5 ] && echo -n "███" ;;
        3) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "  █"; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "███" ;;
        4) [ $row -eq 1 ] && echo -n "█ █"; [ $row -eq 2 ] && echo -n "█ █"; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "  █" ;;
        5) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "█  "; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "███" ;;
        6) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "█  "; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "█ █"; [ $row -eq 5 ] && echo -n "███" ;;
        7) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "  █"; [ $row -eq 3 ] && echo -n "  █"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "  █" ;;
        8) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "█ █"; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "█ █"; [ $row -eq 5 ] && echo -n "███" ;;
        9) [ $row -eq 1 ] && echo -n "███"; [ $row -eq 2 ] && echo -n "█ █"; [ $row -eq 3 ] && echo -n "███"; [ $row -eq 4 ] && echo -n "  █"; [ $row -eq 5 ] && echo -n "███" ;;
        :) [ $row -eq 1 ] && echo -n "   "; [ $row -eq 2 ] && echo -n " █ "; [ $row -eq 3 ] && echo -n "   "; [ $row -eq 4 ] && echo -n " █ "; [ $row -eq 5 ] && echo -n "   " ;;
    esac
}

# Fungsi Helper: Expansi Horizontal (Menggunakan SCALE_X)
expand_horizontal() {
    local input=$1
    local output=""
    # Loop karakter string
    for (( k=0; k<${#input}; k++ )); do
        char="${input:$k:1}"
        # Duplikasi karakter sebanyak SCALE_X
        for (( r=0; r<SCALE_X; r++ )); do
            output+="$char"
        done
    done
    echo "$output"
}

# 3. Loop Utama
while true; do
    read -r uptime_seconds _ < /proc/uptime
    uptime_int=${uptime_seconds%.*}
    hours=$((uptime_int / 3600))
    minutes=$(((uptime_int / 60) % 60))
    seconds=$((uptime_int % 60))
    time_string=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)

    # --- MEMBANGUN TAMPILAN ---
    final_lines=()
    
    # Loop baris dasar (1-5)
    for (( row=1; row<=5; row++ )); do
        current_base_line=""
        
        # Susun baris horizontal
        for (( i=0; i<${#time_string}; i++ )); do
            char="${time_string:$i:1}"
            
            # Ambil pola dasar
            base_shape=$(get_base_row "$char" $row)
            
            # Perbesar LEBAR sesuai SCALE_X
            expanded_shape=$(expand_horizontal "$base_shape")
            
            # Spasi antar angka juga ikut diperbesar agar proporsional
            # Gunakan spasi sebanyak SCALE_X
            space_pad=$(printf '%*s' $SCALE_X "") 
            
            current_base_line+="${expanded_shape}${space_pad}"
        done
        
        # Perbesar TINGGI sesuai SCALE_Y
        # Kita duplikasi baris ini ke bawah sebanyak SCALE_Y
        for (( v=0; v<SCALE_Y; v++ )); do
            final_lines+=("$current_base_line")
        done
    done

    # --- CENTERING ---
    shopt -s checkwinsize; (:;:)
    term_width=$COLUMNS
    term_height=$LINES
    
    art_width=${#final_lines[0]}
    total_height=${#final_lines[@]}
    
    pad_left=$(((term_width - art_width) / 2))
    pad_top=$(((term_height - total_height) / 2))
    
    # Pastikan padding tidak negatif
    [[ $pad_left -lt 0 ]] && pad_left=0
    [[ $pad_top -lt 0 ]] && pad_top=0
    
    space_left=$(printf '%*s' $pad_left "")

    # --- RENDER ---
    tput cup 0 0
    for ((i=0; i<pad_top; i++)); do echo; done

    echo -e "${COLOR_CLOCK}"
    for line in "${final_lines[@]}"; do
        echo -e "${space_left}${line}"
    done
    echo -e "${RESET}"
    
    tput ed 
    sleep 1
done
