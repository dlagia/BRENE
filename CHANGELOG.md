# Changelog

# Supports SuSFS 2.2.0 and 2.3.0+

- drop: service.sh and post-mount.sh
- improve: run spoof props after /storage/emulated/0/Android is accessible
- drop: dead feature "hide_modules_img"
- drop: Umount Suspicious Mounts, not needed with SUS_MOUNT
- drop: Hide Suspicious Injections, better use NoMount metamodule
- add: Kernel Version to module description
- drop: webui: Example of detections
- add: new toggle "Spoof OS Patch Level Property"
- add: webui: new section to see Suspicious Mounts
- add: new toggle "Spoof Vendor Security Patch Level Property"
- add: webui: Incompatible Modules again

# Fork dlagia

- fix: gerbang audit ORPHAN yang tidak pernah bisa menyala (config.sh terhitung memakai dirinya sendiri)
- add: gerbang audit baru - setiap toggle wajib punya switch di WebUI, dan semua JavaScript WebUI dicek `node --check`
- fix: `uninstall.sh` menyalakan kembali manajer SuSFS bawaan ksud yang dimatikan saat install
- fix: WebUI "Reset Settings" menampilkan nilai default yang baru ditulis, bukan nilai sebelum reset
- add: install membuang kunci config yang sudah tidak dikenal modul (mis. toggle yang diganti nama upstream)
- fix: `ro.boot.vbmeta.size` tidak lagi ditulis kosong kalau partisi vbmeta tidak ada
- improve: WebUI "Suspicious Mounts" menampilkan `None` alih-alih blok kosong
- improve: rilis tahan re-run, dependency dipin (`actions/checkout` SHA v7.0.1, prettier 3.9.8)
- fix: nilai Custom Spoof Uname / Verified Boot Hash tidak lagi merusak `config.sh` (escape shell + sed)
- fix: tombol Verified Boot Hash tidak lagi melapor sukses saat kolomnya kosong
- fix: glob kosong tidak lagi dikirim ke susfs sebagai path (`/data/local/tmp/*` dan dua saudaranya)
