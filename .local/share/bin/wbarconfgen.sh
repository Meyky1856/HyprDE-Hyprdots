#!/usr/bin/env bash

# read control file and initialize variables
export scrDir="$(dirname "$(realpath "$0")")"
source "${scrDir}/globalcontrol.sh"
waybar_dir="${confDir}/waybar"
conf_file="$waybar_dir/config.jsonc" # Ini adalah file TARGET
conf_ctl="$waybar_dir/config.ctl"

readarray -t read_ctl < $conf_ctl
num_files="${#read_ctl[@]}"
switch=0
reload_flag=0 # Inisialisasi reload_flag

# update control file to set next/prev mode
if [ $num_files -gt 1 ]; then
    for (( i=0 ; i<$num_files ; i++ )); do
        flag=`echo "${read_ctl[i]}" | cut -d '|' -f 1`
        if [ $flag -eq 1 ] && [ "$1" == "n" ] ; then
            nextIndex=$(( (i + 1) % $num_files ))
            switch=1
            break;
        elif [ $flag -eq 1 ] && [ "$1" == "p" ] ; then
            nextIndex=$(( i - 1 ))
            if [ $nextIndex -lt 0 ] ; then # Perbaikan untuk wrap-around
                nextIndex=$(( $num_files - 1 ))
            fi
            switch=1
            break;
        fi
    done
fi

if [ $switch -eq 1 ] ; then
    update_ctl="${read_ctl[nextIndex]}"
    reload_flag=1
    sed -i "s/^1/0/g" $conf_ctl
    awk -F '|' -v cmp="$update_ctl" '{OFS=FS} {if($0==cmp) $1=1; print$0}' $conf_ctl > $waybar_dir/tmp && mv $waybar_dir/tmp $conf_ctl
fi


# ===================================================================
# BAGIAN YANG DIMODIFIKASI: Salin config berdasarkan config.ctl
# ===================================================================

# Ambil posisi (bottom, left, top, right) dari baris aktif di config.ctl
export w_position=`grep '^1|' $conf_ctl | cut -d '|' -f 3`

if [ -z "$w_position" ]; then
    echo "Error: Tidak dapat menentukan posisi waybar dari $conf_ctl"
    exit 1
fi

# Tentukan file SUMBER config berdasarkan posisi
source_conf_file="$waybar_dir/config-${w_position}.jsonc"

if [ ! -f "$source_conf_file" ]; then
    echo "Error: File config sumber tidak ditemukan: $source_conf_file"
    exit 1
fi

# Salin file config yang dipilih ke config.jsonc target
cp "$source_conf_file" "$conf_file"
echo "Waybar config disalin dari: $source_conf_file"

# ===================================================================
# BAGIAN PEMBUATAN MODUL (envsubst, gen_mod, dll) TELAH DIHAPUS
# ===================================================================


# generate style
# wbarstylegen.sh mungkin masih membutuhkan $w_position
$scrDir/wbarstylegen.sh
