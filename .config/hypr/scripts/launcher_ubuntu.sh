#!/bin/bash

# Variabel konfigurasi
VM_NAME="Ubuntu"
URI="qemu:///system"

echo "--- Launcher VM: $VM_NAME ---"

# 1. Cek status VM terlebih dahulu
# Ini lebih rapi daripada sekadar menggunakan "|| true" karena kita bisa memberi pesan yang jelas.
if virsh --connect "$URI" list --state-running --name | grep -q "^$VM_NAME$"; then
    echo "[INFO] VM '$VM_NAME' sudah berjalan."
else
    echo "[INFO] Menyalakan VM '$VM_NAME'..."
    virsh --connect "$URI" start "$VM_NAME"
fi

# 2. Buka Virt-Viewer
# --wait : Ini kuncinya. Viewer akan menunggu sampai VM benar-benar siap dan memiliki display.
# &      : (Opsional) Menjalankan viewer di background agar terminal Anda tidak terkunci.
echo "[INFO] Menunggu display siap..."
virt-viewer --connect "$URI" --domain-name "$VM_NAME" --full-screen --wait &

echo "[INFO] Selesai."
