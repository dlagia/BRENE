# Changelog

# Supports SuSFS 2.2.0, 2.3.0 and 2.3.0+

- add: webui: "Check Play Integrity API" button
- add: new incompatible modules (Integrity Box, mountify)
- add: new incompatible modules (fgetpriority, Tricky Store OSS, Oh My Keymint, Yurikey Manager, ZNNext)
- add: SuSFS variant to module description
- improve: webui: move "Check Play Integrity API" button to HOME section
- add: webui: Material Files to Recommendations
- improve: update susfs_total_features value to 10 (CONFIG_KSU_SUSFS_PRIORITY_UID_FILTER)
- improve: webui: Check PI API: use "cmd activity" instead of "am" and use force-stop ${PKG} before start ${PKG}/.MainActivity
- improve: webui: use "cmd activity" instead of "am" for all code
- improve: webui: add Advanced separator
- improve: remove Termux and BakaSU/ReSukiSU app external directory
- improve: remove SukiSU Ultra app external directory
- improve: move update_config_date function call atfer /storage/emulated/0/Android is accessible
- drop: Spoof UTC/date/fingerprint properties

# Fork dlagia

- merge: upstream afc5620 (toggle "Spoof fingerprint/UTC/date properties" dibuang) kini diikuti juga. dlagia.16 sempat mempertahankannya atas dasar catatan lama (ROM AxionOS); uji di HP 2026-11-02 menunjukkan ROM-nya MIUI stok V14.0.11.0.TKLMIXM, nilai asli tiap partisi memang berbeda (vendor/odm Android 12 `SP1A`, system `missi`), toggle itu hanya menimpanya jadi satu nilai, dan seluruh vonis Duck Detector identik dengan atau tanpa spoof (docs bagian 17.1)
- merge: upstream v0.0.75 (`3ea96a6..ca4b4f5`): varian SuSFS di deskripsi modul (`susfs show variant`; kernel rosemary melapor `NON-GKI`), `susfs_total_features` 10 (`CONFIG_KSU_SUSFS_PRIORITY_UID_FILTER`, ada di kernel rosemary sejak dlagia/test revisi ke-114), `remove_ksu_directory.sh` ikut menghapus direktori eksternal SukiSU Ultra dan Termux, WebUI: `cmd activity` menggantikan `am`, Material Files, pemisah Advanced, modul tak kompatibel baru
- fix: `update_config_date` tetap dipanggil sebelum spoof patch level di boot-completed (upstream v0.0.75 memindahnya ke akhir script, jadi boot itu memakai tanggal boot sebelumnya), tetap sesudah `/storage/emulated/0/Android` siap
- merge: upstream v0.0.74 (`70a57e2..3ea96a6`): installer hanya menerima SuSFS v2.2.0/v2.3.0/v2.4.0 (kernel rosemary melapor `v2.3.0`), cek version code KernelSU dimatikan upstream, modul ReSuSFS ikut dimatikan, `remove_ksu_directory.sh` ikut menghapus direktori eksternal HMA OSS, `cmd package` menggantikan `pm`, WebUI: tombol "Check Play Integrity API", modul Re-Malwack dan modul tak kompatibel baru
- keep: "Spoof /proc/[cmdline|bootconfig]" tetap mendukung NON-GKI (`/proc/cmdline`); upstream d445dda9f membuang cabang itu, padahal kernel rosemary 4.14 NON-GKI tanpa `/proc/bootconfig` dan cabang itulah yang membuat `verifiedbootstate=green` terbaca app (diuji di HP 2026-10-31)
- merge: upstream v0.0.73 (`45fe52f..70a57e2`): toggle "SELinux Enforcing" (`config_selinux`) dibuang upstream, `remove_ksu_directory.sh` menunggu 1 detik sebelum menghapus (manager KernelSU crash), WebUI: modul tak kompatibel baru, teks lebih ringkas
- merge: upstream sesudah v0.0.72 (`3cff142..45fe52f`): toggle "Hide KernelSU directories", toggle "Hide third party apps" (`set_priority_uid_filter`), biner `susfs` susfs4ksu `35cbfe11`
- fix: "Hide third party apps" menunggu penyimpanan CE user 0 siap (di latar, maks 300 detik) dan hanya mengirim app user 0; dulu satu paket yang belum bisa di-resolve kernel membuat seluruh daftar ditolak
- fix: `remove_ksu_directory.sh` diberi shebang `/system/bin/sh` karena dieksekusi langsung oleh inotifyd, dan ikut menghapus direktori manager BakaSU (`com.resukisu.resukisu`)
- improve: gerbang ORPHAN di workflow rilis memindai semua `module/*.sh` (kecuali `config.sh`), bukan daftar tetap
- fix: binari SuSFS cadangan dipulihkan SEBELUM `susfs show variant` dibaca di post-fs-data, dan hanya kalau cadangannya ada
- improve: installer tanpa hot install (BakaSU sebelum `c06e7ca16`) tetap memasang modul langsung, jadi WebUI siap tanpa reboot seperti sebelumnya
- fix: install membuang salinan tersimpan `persist.logd.size` / prop phantom procs yang ditulis versi lama dengan `resetprop -p`, supaya mematikan toggle-nya kembali berlaku sesudah reboot
- fix: patch level tidak lagi di-spoof jadi `2026--01` pada tanggal 1-4 Agustus dan September (busybox ash membaca bulan `08`/`09` sebagai oktal)
- fix: `CURRENT_DAY` ikut divalidasi, ikut diisi "Reset Settings" di WebUI, dan tahun/bulan/hari diambil dari satu panggilan `date`
- fix: `custom_open_redirect.txt` dibaca lewat `brene_read_list` (baris terakhir tanpa newline tidak hilang, CR tidak ikut ke uid_scheme)
- fix: berkas palsu `/system/etc/hosts` kini 56 byte, sama dengan ukuran yang di-spoof `add_sus_kstat_statically` (dulu 57)
- improve: cek fitur kernel saat install tahu "Spoof /system/etc/hosts" kini juga butuh `CONFIG_KSU_SUSFS_OPEN_REDIRECT`
- fix: uninstall menghapus `persist.logd.size` dan prop phantom procs yang ditulis BRENE, hanya kalau toggle-nya menyala dan nilainya belum diubah
- fix: tanggal patch level tidak diperbarui kalau `date` memulangkan bentuk rusak (dulu `bad number` di log)
- fix: "Remove Custom ROM Properties" dan "Remove Play Integrity Fix Properties" hanya mencocokkan NAMA prop; dulu prop stok yang NILAINYA menyebut ROM (`ro.product.name`, `ro.build.display.id`, `ro.build.flavor`) ikut terhapus
- fix: baris terakhir `custom_*.txt` tanpa newline tidak lagi hilang, dan CR dari berkas Windows dibuang
- fix: `module/tools/susfs` ditandai binary di `.gitattributes`, supaya byte CR di binari baru tidak dibuang git
- fix: `inotify.sh` punya shebang `/system/bin/sh` (dieksekusi langsung oleh inotifyd)
- improve: catatan rilis tidak lagi menulis version code ReSukiSU yang basi
- fix: gerbang audit ORPHAN yang tidak pernah bisa menyala (config.sh terhitung memakai dirinya sendiri)
- add: gerbang audit baru - setiap toggle wajib punya switch di WebUI, dan semua JavaScript WebUI dicek `node --check`
- fix: `uninstall.sh` menyalakan kembali manajer SuSFS bawaan ksud yang dimatikan saat install
- fix: WebUI "Reset Settings" menampilkan nilai default yang baru ditulis, bukan nilai sebelum reset
- add: install membuang kunci config yang sudah tidak dikenal modul (mis. toggle yang diganti nama upstream)
- fix: `ro.boot.vbmeta.size` tidak lagi ditulis kosong kalau partisi vbmeta tidak ada
- improve: WebUI "Suspicious Mounts" menampilkan `No mounts` (teks upstream sejak v0.0.73) alih-alih blok kosong, juga kalau keluarannya hanya newline
- improve: rilis tahan re-run, dependency dipin (`actions/checkout` SHA v7.0.1, prettier 3.9.9)
- fix: nilai Custom Spoof Uname / Verified Boot Hash tidak lagi merusak `config.sh` (escape shell + sed)
- fix: tombol Verified Boot Hash tidak lagi melapor sukses saat kolomnya kosong
- fix: glob kosong tidak lagi dikirim ke susfs sebagai path (`/data/local/tmp/*` dan dua saudaranya)
- fix: `config_rom_props` tidak lagi menghapus `ro.build.fingerprint` (grep ikut mencocokkan nilai prop)
- fix: Verified Boot Hash di-trim sebelum disimpan, spasi saja tidak lagi di-spoof ke `ro.boot.vbmeta.digest`
- fix: Apply sus path hanya mengganti awalan `/sdcard`, bukan setiap kemunculan di tengah path
- fix: indeks swipe tab tidak lagi mulai dari -1
- fix: patch level tidak lagi di-spoof jadi `--01` / `--05` sesudah "Reset Settings" (CURRENT_YEAR/CURRENT_MONTH kosong)
- fix: jam yang belum tersinkron tidak lagi menimpa tanggal patch level tersimpan, dan boot-completed memakai tanggal yang baru ditulis
- fix: gerbang ORPHAN tidak lagi membaca nama fungsi `update_config_date` sebagai toggle `config_date`
- fix: uninstall tidak lagi menghapus hard link `ksu_susfs` yang baru dibuat ulang `ksud susfs config enable`
- improve: WebUI "Reset Settings" langsung mengisi tanggal patch level
