#!/system/bin/sh
# shellcheck disable=SC2154
# Fork dlagia: satu-satunya script modul yang DIEKSEKUSI langsung (oleh
# inotifyd di boot-completed.sh), bukan dijalankan ksud lewat busybox sh.
# Tanpa shebang, eksekusinya bergantung pada fallback ENOEXEC di execvp.
# Shebang /bin/bash seperti script lain justru gagal: Android tidak punya
# /bin/bash.
# Remove "..5.u.S"
TARGET="..5.u.S"
TARGET1="/storage/emulated/0/${TARGET}"
TARGET2="/storage/emulated/0/Android/data/${TARGET}"
TARGET3="/storage/emulated/0/Android/media/${TARGET}"
TARGET4="/storage/emulated/0/Android/obb/${TARGET}"
rm -rf "${TARGET1}" "${TARGET2}" "${TARGET3}" "${TARGET4}"
