# Changelog

# Supports SuSFS 2.2.0 and 2.3.0+

- add: new toggle "Hide KernelSU directories"
- improve: update susfs binary to support "set_priority_uid_filter"
- add: new toggle "Hide third party apps"
- drop: webui: "UID Filter" module
- improve: webui: more minimal changes
- drop: "SELinux Enforcing" option
- add: webui: new incompatible modules

# Fork dlagia

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
