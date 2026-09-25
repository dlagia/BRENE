#!/bin/bash
# shellcheck disable=SC2154
MODDIR=${0%/*}
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

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
