# Changelog

# Supports SuSFS 2.2.0 and 2.3.0+

- refactor: "Spoof OS/Vendor Security Patch Level Property" and fix issues on some devices (1970 issue)
- improve: add total SuSFS features to module description
- change: enable "Hide Non-standard /storage/emulated/0 Paths" by default
- improve: spoof ro.secureboot.devicelock prop
- improve: webui: update descriptions, change order, and minor fixes and improvements
- improve: spoof ro.oem_unlock_supported prop to 0 (hide OEM unlocking toggle)

# Fork dlagia

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
- improve: WebUI "Suspicious Mounts" menampilkan `None` alih-alih blok kosong
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
