#!/system/bin/sh
# shellcheck disable=SC2154
# Fork dlagia: seperti inotify.sh, script ini DIEKSEKUSI langsung oleh inotifyd
# di boot-completed.sh, jadi butuh shebang /system/bin/sh (alasannya di
# inotify.sh). Pengganti `# shellcheck disable=SC2148` upstream.
remove_directory() {
	if [[ -z "$1" ]]; then
		return 1
	fi

	local TARGET1="/storage/emulated/0/Android/data/$1"
	local TARGET2="/storage/emulated/0/Android/media/$1"
	local TARGET3="/storage/emulated/0/Android/obb/$1"
	rm -rf "${TARGET1}" "${TARGET2}" "${TARGET3}"
}

remove_directory "me.weishu.kernelsu"
remove_directory "com.rifsxd.ksunext"
# Tambahan fork dlagia: package bawaan manager BakaSU (eks-ReSukiSU), KernelSU
# di kernel rosemary dlagia/test (defaultManagerPackageName di
# manager/build.gradle.kts). Manager dengan package acak tidak bisa ditebak.
remove_directory "com.resukisu.resukisu"
