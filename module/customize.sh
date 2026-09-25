#!/bin/bash
# shellcheck disable=SC2154
KSU_BIN=/data/adb/ksud
KSU_MODULES_DIR=/data/adb/modules
SUSFS_BIN=/data/adb/ksu/bin/susfs
PERSISTENT_DIR=/data/adb/brene
DEST_BIN_DIR=/data/adb/ksu/bin

# Load utils
[[ -e "${MODPATH}/utils.sh" ]] && source "${MODPATH}/utils.sh"

echo ""
echo "██████╗ ██████╗ ███████╗███╗   ██╗███████╗"
echo "██╔══██╗██╔══██╗██╔════╝████╗  ██║██╔════╝"
echo "██████╔╝██████╔╝█████╗  ██╔██╗ ██║█████╗  "
echo "██╔══██╗██╔══██╗██╔══╝  ██║╚██╗██║██╔══╝  "
echo "██████╔╝██║  ██║███████╗██║ ╚████║███████╗"
echo "╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝╚══════╝"
echo ""

# Check Compatibility
if [[ -z "${KSU}" ]]; then
	abort '[❌] SuSFS is only for KernelSU or forks!'
fi

if [[ "${ARCH}" != "arm64" ]]; then
	abort '[❌] Only arm64 is supported!'
fi

if [[ "${KSU_KERNEL_VER_CODE}" -ge 32336 ]]; then
	echo "[✅] Detected KernelSU kernel version: ${KSU_KERNEL_VER_CODE}"
else
	abort "[❌] Unsupported KernelSU kernel version: ${KSU_KERNEL_VER_CODE}!"
fi

if [[ ! -d "${DEST_BIN_DIR}" ]]; then
	abort "[❌] '${DEST_BIN_DIR}' not existed, installation aborted!"
fi

cp -f "${MODPATH}/tools/susfs" "${DEST_BIN_DIR}"
chmod +x "${MODPATH}/inotify.sh"
chmod 755 "${DEST_BIN_DIR}/susfs"
ln -sf "${DEST_BIN_DIR}/susfs" "${DEST_BIN_DIR}/sus"       # For development
ln -sf "${DEST_BIN_DIR}/susfs" "${DEST_BIN_DIR}/ksu_susfs" # For compatibility

susfs_version=$(${SUSFS_BIN} show version)
if [[ "${susfs_version}" == "v2"* ]]; then
	echo "[✅] Detected SuSFS version: ${susfs_version}"
else
	abort "[❌] Not supported SuSFS version ${susfs_version}!"
fi

# Reset module description
susfs_total_features=9
susfs_variant=$(${SUSFS_BIN} show variant)
susfs_features_number=$(${SUSFS_BIN} show enabled_features | wc -l)
kernel_version=$(cat /proc/version | awk '{print $3}' | grep -oE '^[0-9]+\.[0-9]+\.[0-9]+')
description="A SuSFS/KernelSU module for SuSFS patched kernels"
status="Waiting for reboot ⏱️"
${KSU_BIN} module config set override.description "[Status: ${status} | Kernel Version: ${kernel_version} | SuSFS: ${susfs_version} (${susfs_variant}) | SuSFS Features: ${susfs_features_number}/${susfs_total_features} enabled] ${description}"

# Disable other SuSFS modules
[[ -e "${KSU_MODULES_DIR}/susfs4ksu" ]] && {
	touch "${KSU_MODULES_DIR}/susfs4ksu/disable" && echo '[✅] Disabling other SuSFS module'
}
[[ -e "${KSU_MODULES_DIR}/susfs_manager" ]] && {
	touch "${KSU_MODULES_DIR}/susfs_manager/disable" && echo '[✅] Disabling other SuSFS module'
}

echo '[✅] Preparing brene persistent directory (/data/adb/brene)'
mkdir -p "${PERSISTENT_DIR}"

files="
custom_sus_map.txt
custom_kernel_umount.txt
custom_sus_path.txt
custom_sus_path_loop.txt
"
for file in ${files}; do
	if [[ ! -f "${PERSISTENT_DIR}/${file}" ]]; then
		touch "${PERSISTENT_DIR}/${file}" && echo "[✅] Added ${file}"
	fi
done

if [[ ! -f "${PERSISTENT_DIR}/config.sh" ]]; then
	cp "${MODPATH}/config.sh" "${PERSISTENT_DIR}" && echo '[✅] Added config.sh'
else
	while IFS='=' read -r key value || [[ -n "${key}" ]]; do

		# Skip empty lines or comments
		[[ -z "${key// /}" || "${key// /}" == "#"* ]] && continue

		if grep -q "^${key}=" "${PERSISTENT_DIR}/config.sh"; then
			:
		else
			echo "${key}=${value}" >> "${PERSISTENT_DIR}/config.sh"
			echo "[➕] Added missing key=value: ${key}=${value}"
		fi

	done < "${MODPATH}/config.sh"

	# Tambahan fork dlagia: buang kunci yang sudah tidak dikenal modul.
	# Loop di atas hanya MENAMBAH kunci baru, tidak pernah membuang yang lama,
	# jadi rename di upstream (v0.0.68: config_spoof_os_patch_level_property ->
	# config_spoof_os_security_patch_level_property) meninggalkan kunci mati di
	# /data/adb/brene/config.sh selamanya - toggle-nya tidak dibaca script mana
	# pun, tapi tetap terlihat di WebUI-nya sendiri dan membingungkan saat audit.
	grep -oE '^config_[a-z0-9_]+' "${PERSISTENT_DIR}/config.sh" | while read -r key; do
		grep -q "^${key}=" "${MODPATH}/config.sh" && continue

		sed -i "/^${key}=/d" "${PERSISTENT_DIR}/config.sh"
		echo "[➖] Removed obsolete key: ${key}"
	done
fi

update_config_date

# Remove fake_files folder
[[ -d "${PERSISTENT_DIR}/fake_files" ]] && rm -rf "${PERSISTENT_DIR}/fake_files"

# ============================================================================
# Tambahan fork dlagia (lihat docs/AUDIT-KERNEL-DLAGIA.md)
# ============================================================================
# 1. Serah-terima kendali SuSFS dari ksud ke BRENE.
#    ReSukiSU/SukiSU punya manajer SuSFS sendiri di dalam ksud
#    (`ksud susfs config`) dan defaultnya AKTIF. Pada boot-completed manajer itu
#    jalan SESUDAH script modul, lalu menerapkan config-nya sendiri (cmdline
#    kosong, sus_path kosong, dst) sehingga bisa menimpa yang baru dipasang
#    BRENE. Matikan sekali di sini. ksud hanya melepas hard link ksu_susfs
#    miliknya sendiri; symlink ksu_susfs punya BRENE di atas tidak diganggu.
#    Fork KernelSU tanpa subcommand ini akan gagal di sini, dan itu tidak apa-apa.
if ${KSU_BIN} susfs config disable > /dev/null 2>&1; then
	echo '[✅] Manajer SuSFS bawaan ksud dimatikan, BRENE yang pegang kendali'
else
	echo '[ℹ️] ksud tanpa manajer SuSFS bawaan, langkah ini dilewati'
fi

# 2. Cocokkan toggle yang menyala di config.sh dengan fitur SuSFS yang benar-
#    benar dikompilasi di kernel. Tidak fatal: toggle tanpa dukungan kernel
#    hanya diam-diam tidak berefek, jadi lebih baik dilaporkan saat install.
enabled_features=$(${SUSFS_BIN} show enabled_features 2> /dev/null)
missing_features=0
cfg_needs="
config_paths_hiding__non_standard_sdcard=CONFIG_KSU_SUSFS_SUS_PATH
config_paths_hiding__non_standard_sdcard_android=CONFIG_KSU_SUSFS_SUS_PATH
config_paths_hiding__data_local_tmp=CONFIG_KSU_SUSFS_SUS_PATH
config_hide_custom_recovery=CONFIG_KSU_SUSFS_SUS_PATH
config_hide_suspicious_pty=CONFIG_KSU_SUSFS_SUS_PATH
config_hide_custom_rom_paths=CONFIG_KSU_SUSFS_SUS_PATH
config_hide_custom_rom_paths_2=CONFIG_KSU_SUSFS_SUS_PATH
config_hide_addon_d=CONFIG_KSU_SUSFS_SUS_MAP
config_hide_framework_res_apk=CONFIG_KSU_SUSFS_SUS_MAP
config_hide_sus_mnts_for_non_su_procs=CONFIG_KSU_SUSFS_SUS_MOUNT
config_fix_data_local_tmp_inconsistencies=CONFIG_KSU_SUSFS_SUS_KSTAT
config_spoof_hosts=CONFIG_KSU_SUSFS_SUS_KSTAT
config_spoof_uname=CONFIG_KSU_SUSFS_SPOOF_UNAME
config_custom_spoof_uname=CONFIG_KSU_SUSFS_SPOOF_UNAME
config_spoof_cmdline_or_bootconfig=CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG
config_spoof_libstagefright=CONFIG_KSU_SUSFS_OPEN_REDIRECT
config_hide_lineage_strings=CONFIG_KSU_SUSFS_OPEN_REDIRECT
config_enable_log=CONFIG_KSU_SUSFS_ENABLE_LOG
"
for pair in ${cfg_needs}; do
	cfg_key=${pair%%=*}
	needed_feature=${pair#*=}

	[[ "$(grep -m1 "^${cfg_key}=" "${PERSISTENT_DIR}/config.sh" | cut -d'=' -f2)" == "1" ]] || continue

	if ! echo "${enabled_features}" | grep -q "^${needed_feature}$"; then
		echo "[⚠️] ${cfg_key}=1 butuh ${needed_feature}, kernel ini tidak punya - toggle itu tidak akan berefek"
		missing_features=$((missing_features + 1))
	fi
done

if [[ "${missing_features}" == "0" ]]; then
	echo "[✅] Semua toggle yang menyala didukung kernel (${susfs_features_number} fitur SuSFS aktif)"
else
	echo "[⚠️] ${missing_features} toggle tidak didukung kernel, matikan lewat WebUI atau bangun ulang kernel dengan fitur itu"
fi

# Enable WebUI without reboot
MODDIR="/data/adb/modules/brene"
MODULES_PATH="/data/adb/modules"

rm -rf "${MODDIR}"
cp -rp "${MODPATH}" "${MODULES_PATH}"

(
	sleep 3
	rm -rf "${MODPATH}"
	rm "${MODDIR}/update"
) & # fork in background

echo '[✅] WebUI is ready!'
