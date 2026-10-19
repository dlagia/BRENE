#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

# Tambahan fork dlagia: sampai v0.0.71 boot-completed.sh menulis dua prop
# PERSIST dengan `resetprop -p` (keduanya menyala secara default). Sejak v0.0.72
# ditulis tanpa -p dan customize.sh membuang salinan tersimpan dari versi lama,
# jadi baris di bawah tinggal jaring pengaman: prop persist yang tersimpan
# bertahan sesudah modul dibongkar, dan tanpa ini buffer logcat tetap 64K dan
# pembatasan proses anak tetap mati selamanya. Dihapus hanya kalau toggle-nya
# menyala di config.sh (dibaca SEBELUM folder itu dihapus) DAN nilainya masih
# persis nilai yang ditulis BRENE. Toggle mati = prop milik pemilik (mis. dari
# Opsi Pengembang), dibiarkan.
brene_toggle_on() {
	[[ "$(grep -m1 "^$1=" "${PERSISTENT_DIR}/config.sh" 2> /dev/null | cut -d'=' -f2)" == "1" ]]
}
if brene_toggle_on config_shrink_buffer_size && [[ "$(getprop persist.logd.size)" == "65536" ]]; then
	resetprop -p -d persist.logd.size
fi
if brene_toggle_on config_disable_child_process_restrictions && [[ "$(getprop persist.sys.fflag.override.settings_enable_monitor_phantom_procs)" == "false" ]]; then
	resetprop -p -d persist.sys.fflag.override.settings_enable_monitor_phantom_procs
fi

rm -rf "${PERSISTENT_DIR}"
rm -f "${SUSFS_BIN}"
rm -f "${DEST_BIN_DIR}/sus"
rm -f "${DEST_BIN_DIR}/ksu_susfs"

# Tambahan fork dlagia: kembalikan kendali SuSFS ke ksud.
# customize.sh mematikan manajer SuSFS bawaan ksud (`ksud susfs config disable`)
# supaya tidak menimpa konfigurasi BRENE di tahap boot-completed. Kalau BRENE
# dibongkar tanpa menyalakannya kembali, perangkat tertinggal tanpa manajer
# SuSFS sama sekali: BRENE sudah tidak ada, ksud masih dimatikan. `Enable` ada
# di ReSukiSU (userspace/ksud/src/android/susfs/config/cli.rs, ConfigCommand).
# Fork KernelSU tanpa subcommand ini gagal di sini, dan itu tidak apa-apa.
#
# Harus SESUDAH rm di atas: `enable` membuat ulang hard link ksu_susfs -> ksud
# (assets.rs, reconcile_susfs_link). Kalau dijalankan lebih dulu, rm di atas
# langsung menghapus hard link baru itu.
if ${KSU_BIN} susfs config enable > /dev/null 2>&1; then
	echo "Manajer SuSFS bawaan ksud dinyalakan kembali"
fi
