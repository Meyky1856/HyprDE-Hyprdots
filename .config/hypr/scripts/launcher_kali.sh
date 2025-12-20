#!/bin/bash

# Definisikan nama VM dan URI agar mudah diubah
VM_NAME="Kali"
URI="qemu:///system"

echo "Memulai VM: $VM_NAME..."

# 1. Start VM
# Menggunakan 'virsh start'
# Kita cek dulu apakah sudah running untuk menghindari pesan error yang membingungkan,
# meski "|| true" di script Anda sebenarnya sudah cukup aman.
if ! virsh --connect $URI list --state-running --name | grep -q "^$VM_NAME$"; then
    virsh --connect $URI start $VM_NAME
else
    echo "VM $VM_NAME sudah berjalan."
fi

# 2. Buka Viewer
# Tambahkan '--wait' agar viewer menunggu VM siap
# Tambahkan '&' di akhir jika ingin script ini selesai tanpa menunggu jendela viewer ditutup (opsional)
echo "Membuka display..."
virt-viewer --connect $URI --domain-name $VM_NAME --full-screen --wait
