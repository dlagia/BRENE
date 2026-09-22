# Audit BRENE untuk kernel dlagia/test (rosemary 4.14)

Tanggal audit: 2026-09-21.
Yang diaudit: `dlagia/BRENE` @ `b255fec` (identik dengan upstream `rrr333nnn333/BRENE` HEAD)
terhadap kernel `dlagia/test` revisi ke-42c (run build `35499235046`, sukses).

## 1. Yang dipakai kernel ini

| Komponen          | Nilai                                       | Sumber                       |
| ----------------- | ------------------------------------------- | ---------------------------- |
| Kernel            | Xiaomi rosemary, 4.14, NON-GKI              | `KERNEL_PIN=602782da`        |
| KernelSU          | ReSukiSU `6d18926a`, version code **35158** | log build: `ReSukiSU 35158`  |
| SuSFS             | **v2.3.0**, varian **NON-GKI**              | patch JackA1ltman `ac370f5d` |
| Fitur SuSFS aktif | 9 (lihat tabel di bawah)                    | `out/.config` di log build   |

## 2. Gerbang kompatibilitas BRENE

`module/customize.sh` menolak install kalau salah satu tidak terpenuhi:

| Syarat                             | Kernel ini  | Status           |
| ---------------------------------- | ----------- | ---------------- |
| `$KSU` terisi (KernelSU atau fork) | ReSukiSU    | ✅               |
| `$ARCH` = arm64                    | arm64       | ✅               |
| `KSU_KERNEL_VER_CODE` ≥ 32336      | 35158       | ✅ (margin 2822) |
| `susfs show version` diawali `v2`  | v2.3.0      | ✅               |
| `/data/adb/ksu/bin` ada            | dibuat ksud | ✅               |

**Catatan penting soal 35158.** Angka itu dihitung `kernel/Kbuild` ReSukiSU sebagai
`30000 + $(git rev-list --count HEAD) + 700`. Artinya version code bergantung pada
**riwayat git** klon ReSukiSU saat kernel dibangun, bukan pada isi kodenya. Kalau suatu
saat klon ReSukiSU di workflow berubah jadi dangkal (`--depth 1`) dan Kbuild gagal
meng-`unshallow`, version code jatuh ke ±30701 dan **BRENE menolak terpasang** dengan
pesan "Unsupported KernelSU kernel version". `kernel/setup.sh` yang dipakai sekarang
melakukan klon penuh, jadi aman - tapi ini yang pertama dicek kalau install tiba-tiba
ditolak setelah menaikkan `KSU_PIN`.

## 3. Fitur SuSFS: yang dibutuhkan BRENE vs yang ada di kernel

| Fitur kernel                                   | Ada? | Dipakai BRENE untuk                                                          |
| ---------------------------------------------- | ---- | ---------------------------------------------------------------------------- |
| `CONFIG_KSU_SUSFS_SUS_PATH`                    | ✅   | sembunyikan path non-standar di `/sdcard`, `/data/local/tmp`, jejak recovery |
| `CONFIG_KSU_SUSFS_SUS_MOUNT`                   | ✅   | `hide_sus_mnts_for_non_su_procs`                                             |
| `CONFIG_KSU_SUSFS_SUS_KSTAT`                   | ✅   | `spoof_hosts`, `fix_data_local_tmp_inconsistencies`                          |
| `CONFIG_KSU_SUSFS_SUS_MAP`                     | ✅   | `hide_addon_d`, `hide_framework_res_apk`                                     |
| `CONFIG_KSU_SUSFS_SPOOF_UNAME`                 | ✅   | `spoof_uname`, `custom_spoof_uname`                                          |
| `CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG` | ✅   | `spoof_cmdline_or_bootconfig` (default mati)                                 |
| `CONFIG_KSU_SUSFS_OPEN_REDIRECT`               | ✅   | `spoof_libstagefright`, `hide_lineage_strings` (default mati)                |
| `CONFIG_KSU_SUSFS_ENABLE_LOG`                  | ✅   | `enable_log`                                                                 |
| `CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS`      | ✅   | tidak dipanggil modul, murni kernel                                          |

Semua dari 14 subperintah `susfs` yang dipanggil BRENE (`add_sus_path`, `add_sus_path_loop`,
`add_sus_map`, `add_sus_kstat`, `add_sus_kstat_statically`, `update_sus_kstat`,
`update_sus_kstat_full_clone`, `add_open_redirect`, `set_uname`, `set_cmdline_or_bootconfig`,
`enable_log`, `enable_avc_log_spoofing`, `hide_sus_mnts_for_non_su_procs`, `show`)
ada di patch SuSFS v2.3.0 yang dipakai kernel ini. **Tidak ada yang hilang.**

Sejak install, `customize.sh` juga mencocokkan sendiri toggle yang menyala di
`/data/adb/brene/config.sh` dengan keluaran `susfs show enabled_features`, dan memberi
peringatan (tidak fatal) untuk toggle yang tidak didukung kernel.

## 4. Kecocokan perintah `ksud`

BRENE memanggil `ksud` di luar API SuSFS. Semua terverifikasi ada di ReSukiSU `6d18926a`:

| Panggilan BRENE                                                            | Ada di ReSukiSU                                        |
| -------------------------------------------------------------------------- | ------------------------------------------------------ |
| `ksud module config set override.description`                              | ✅                                                     |
| `ksud feature set su_compat\|kernel_umount\|selinux_hide` + `feature save` | ✅                                                     |
| `ksud kernel umount add -f 2 <mnt>`                                        | ✅                                                     |
| `ksud kernel notify-module-mounted`                                        | ✅                                                     |
| `ksud boot-info current-kmi`                                               | ✅ (hanya dipakai di jalur GKI, tidak kena kernel ini) |
| `resetprop` di `PATH`                                                      | ✅ `/data/adb/ksu/bin/resetprop`                       |
| `busybox` untuk `brene_clone_perm`                                         | ✅ `/data/adb/ksu/bin/busybox`                         |

Script modul dijalankan ksud dengan **busybox sh** (`ASH_STANDALONE=1`), bukan bash,
walaupun shebang-nya `#!/bin/bash`. Konsekuensinya semua applet busybox (`shuf`, `stat`,
`seq`, `find`, `inotifyd`) selalu tersedia tanpa bergantung pada toybox ROM.

## 5. Temuan yang diperbaiki di fork ini

1. **`updateJson` menunjuk upstream.** `module/module.prop` masih mengarah ke
   `raw.githubusercontent.com/rrr333nnn333/...`, jadi manager KernelSU akan menawarkan
   rilis upstream dan **menimpa** fork ini beserta semua perbaikannya. Sekarang menunjuk
   `dlagia/BRENE`.
2. **`zipUrl` menunjuk rilis upstream dan tidak konsisten** (`releases/latest/download/`
   digabung dengan nama file ber-versi `BRENE-v0.0.67.zip`, yang langsung basi begitu
   versi naik). Sekarang `dlagia/BRENE .../latest/download/BRENE.zip` dengan nama aset tetap.
3. **Fork tidak punya rilis sama sekali** (upstream membangun zip manual), jadi
   `updateJson` pasti 404 dan tidak ada zip untuk di-flash. Ditambahkan
   `.github/workflows/rilis-brene.yml`: audit + bangun zip + terbitkan rilis.
4. **Tabrakan dengan manajer SuSFS bawaan ksud.** ReSukiSU punya `ksud susfs config`
   yang **aktif secara default**. Di `post-fs-data` ia jalan _sebelum_ script modul
   (aman, BRENE menimpa belakangan), tapi di `boot-completed` ia jalan _sesudah_ script
   modul dan menerapkan config-nya sendiri - termasuk `set_cmdline_or_bootconfig` dengan
   nilai kosong. Begitu `config_spoof_cmdline_or_bootconfig` dinyalakan di BRENE,
   spoof itu bisa langsung dibatalkan ksud beberapa detik kemudian. `customize.sh`
   sekarang menjalankan `ksud susfs config disable` sekali saat install; ksud hanya
   melepas hard link `ksu_susfs` miliknya sendiri dan tidak menyentuh symlink BRENE.

## 6. Temuan yang dibiarkan (sadar, bukan kelalaian)

- `module/tools/susfs` adalah biner prebuilt tanpa string versi. Kecocokannya dengan
  kernel disimpulkan dari daftar perintah yang didukung (`add_sus_map` dan
  `enable_avc_log_spoofing` hanya ada sejak SuSFS 2.3.0) - bukan dari pembacaan nomor CMD.
  Kalau upstream mengganti biner ini, cek ulang dengan `susfs show version` di perangkat.
- `boot-completed.sh` menunggu `/storage/emulated/0/Android` dengan `until ... sleep 1`
  tanpa batas waktu. ksud menjalankan tahap ini secara non-blocking, jadi tidak bisa
  menahan boot; dibiarkan seperti upstream.
- `brene_clone_perm` memakai process substitution (`< <(...)`) yang butuh busybox
  dengan `BASH_PROCESS_SUBST`. Hanya dipakai oleh `spoof_libstagefright` dan
  `hide_lineage_strings`, keduanya default mati.
- Sisi kernel: `CONFIG_KSU_SUSFS_TRY_UMOUNT=y` di defconfig `dlagia/Build-Kernel_scripts`
  adalah **simbol yatim** - tidak ada di Kconfig ReSukiSU maupun di patch SuSFS 2.3.0
  (`CMD_SUSFS_ADD_TRY_UMOUNT` ditandai _deprecated_), jadi tidak pernah resolve di
  `out/.config`. Umount sekarang ditangani `ksud feature set kernel_umount` + NoMount.

  **Keputusan: DIBIARKAN, jangan dihapus.** Ini bukan pekerjaan yang tertunda.
  Alasannya sudah tertulis di `dlagia/test` → `.github/workflows/build-kernel-ksu-v2.yml`
  (bagian komentar sebelum langkah "Mengunduh dan menggabungkan ksu-susfs_defconfig"):
  Kconfig membuang baris itu diam-diam dan `try_umount` di ReSukiSU tidak lagi
  digerbangi Kconfig, jadi menghapusnya tidak mengubah satu bit pun di `.config`
  maupun di kernel hasil build. Sebaliknya biayanya nyata: defconfig-nya tinggal di
  repo lain di balik `SCRIPTS_PIN`, sehingga menghapus satu baris mati menuntut
  naikkan pin → build ulang → flash ulang, alias menggeser konfigurasi yang berstatus
  "TITIK TERBUKTI BOOT" (revisi ke-42, commit `5e8e140c`) demi perubahan tanpa efek.
  Audit berikutnya cukup mencatat baris ini sebagai yatim yang diketahui, tanpa
  mengusulkan penghapusan lagi. Yang layak mengubah keputusan ini hanya satu hal:
  kalau ReSukiSU kelak menambahkan kembali simbol `KSU_SUSFS_TRY_UMOUNT`, baris ini
  akan mulai resolve dan perlu diaudit sebagai fitur yang aktif, bukan sebagai yatim.

## 7. Cara pakai

1. ~~Merge PR ini ke `main`.~~ Sudah dilakukan 2026-09-21 (merge commit `214605e`).
2. Workflow **Rilis BRENE** jalan otomatis dan membuat rilis `v0.0.67-dlagia.<nomor build>`
   berisi `BRENE.zip`. Rilis pertama: `v0.0.67-dlagia.2` (build 1 gagal di job audit karena
   variabel loop `config_needs`/`config_key` ikut tertangkap pola cek ORPHAN; sudah diganti
   jadi `cfg_needs`/`cfg_key` di commit `3e77d0e`).
3. Flash `BRENE.zip` lewat manager KernelSU. Update berikutnya akan diambil dari fork ini.
4. Sejak ronde audit kedua (2026-09-22) tag-nya `v0.0.68-dlagia.<nomor build>`, karena
   upstream v0.0.68 sudah digabung. Rincian di bagian 8.

## 8. Audit ronde kedua (2026-09-22)

Yang diaudit: fork di `461fc92` (rilis terpasang `v0.0.67-dlagia.2`) terhadap upstream
`rrr333nnn333/BRENE` HEAD `4156b89` (v0.0.68). Kernelnya tidak diaudit ulang - tidak ada
perintah `susfs`/`ksud` baru yang dipanggil, jadi tabel fitur di bagian 3 masih berlaku.

### 8.1 Upstream v0.0.68 digabung

Empat commit, semuanya aditif dan tidak menyentuh jalur NON-GKI:

| Commit    | Isi                                        | Butuh fitur kernel?             |
| --------- | ------------------------------------------ | ------------------------------- |
| `2cb7772` | WebUI: bagian "Suspicious Mounts"          | tidak, baca `/proc/1/mountinfo` |
| `6809630` | toggle "Spoof Vendor Security Patch Level" | tidak, murni `resetprop`        |
| `c85edb2` | WebUI: bagian "Incompatible Modules"       | tidak, baca `ksud module list`  |
| `4156b89` | bump v0.0.68 (`versionCode` 67 → 68)       | -                               |

`config_spoof_os_patch_level_property` **diganti nama** upstream menjadi
`config_spoof_os_security_patch_level_property`. Kunci lama tertinggal di
`/data/adb/brene/config.sh` pada install lama; sejak ronde ini `customize.sh` membuangnya.

`versionCode` 68 > 67 yang terpasang, jadi manajer KernelSU akan menawarkan build ini
sendiri. **Batasnya:** perubahan yang hanya ada di fork (mis. semua perbaikan di 8.3)
tidak menaikkan `versionCode`, jadi manajer tidak akan memberi notifikasi untuk build
fork berikutnya - zip-nya harus di-flash manual. Ini disengaja: `versionCode` dibiarkan
sama dengan upstream supaya perbandingan versi antar-fork tetap jujur.

### 8.2 ORPHAN dan dependency

- **ORPHAN:** 41 toggle di `config.sh`, **0 yatim** dan **0 dipakai-tanpa-definisi** -
  tapi angka itu baru bisa dipercaya setelah gerbangnya diperbaiki (lihat 8.3 nomor 1).
- **Dependency:** `actions/checkout` `v5` (tag mengambang) → SHA `3d3c42e5` (v7.0.1);
  `prettier` 3.8.2 → 3.9.8; `prettier-plugin-sh` 0.18.1 → 0.19.0. Semua berkas yang
  dimiliki fork lolos `prettier --check` sesudahnya.
- `module/tools/susfs` **tidak berubah** di upstream (ELF arm64, NDK r30-beta2, 23.296 B),
  jadi biner yang terbukti jalan di `v0.0.67-dlagia.2` tetap dipakai apa adanya.
- Tidak ada lockfile di repo (`pnpm-lock.yaml` ada di `.gitignore`). **Dibiarkan:** prettier
  hanya alat lokal, versinya sudah dipin eksak, dan CI tidak pernah menjalankannya.

### 8.3 Bug tersembunyi yang diperbaiki

1. **Cek ORPHAN mandul (gerbang audit, paling serius).** Daftar "pemakai toggle" dipindai
   dari `module/*.sh`, yang **ikut menyertakan `module/config.sh` sendiri**, jadi setiap
   toggle selalu terhitung dipakai oleh barisnya sendiri dan `comm -23` mustahil
   menghasilkan apa pun. Dibuktikan dengan menambahkan `config_uji_yatim=0`: lolos audit
   sebelum diperbaiki, ditolak sesudahnya. Arah sebaliknya (dipakai tapi tak
   didefinisikan) memang sudah bekerja - itu yang menggagalkan build 1.
2. **`uninstall.sh` meninggalkan perangkat tanpa manajer SuSFS.** `customize.sh`
   menjalankan `ksud susfs config disable` saat install (lihat bagian 5 nomor 4), tapi
   uninstall tidak pernah menyalakannya kembali: BRENE hilang, manajer ksud masih mati.
   Sekarang `uninstall.sh` menjalankan `ksud susfs config enable` (subcommand `Enable`
   ada di `userspace/ksud/src/android/susfs/config/cli.rs`).
3. **WebUI "Reset Settings" menampilkan nilai lama.** Sesudah `cp -f` default ke
   `/data/adb/brene/config.sh`, switch di-set ulang dari `configValues` yang direkam
   **sebelum** reset, jadi UI tampak tidak berubah sementara file sudah default.
   Sekarang config dibaca ulang; parser dan pengisian UI diangkat jadi helper
   (`parseConfig`, `applyConfigToUi`) supaya jalur load dan jalur reset tidak bisa
   berbeda lagi.
4. **`ro.boot.vbmeta.size` bisa ditulis kosong.** `blockdev --getsize64` dipanggil
   langsung di dalam `resetprop_n`; kalau partisi `vbmeta` tidak ada, prop-nya diset
   string kosong - justru sinyal aneh yang tidak pernah ada di ROM stok. Sekarang
   hasilnya dicek dulu. (rosemary non-A/B: `slot_suffix` kosong, path-nya
   `/dev/block/by-name/vbmeta`, dan di perangkat ini memang ada.)
5. **Kunci config mati menumpuk selamanya.** `customize.sh` hanya menambah kunci baru,
   tidak pernah membuang yang lama. Sekarang kunci yang tidak ada di `config.sh` modul
   dihapus dari config persisten dan dilaporkan saat install.
6. **Rilis gagal saat job di-re-run.** Tag dibentuk dari `GITHUB_RUN_NUMBER`, jadi re-run
   memakai tag yang sama dan `gh release create` menolaknya. Sekarang asetnya ditimpa
   dengan `gh release upload --clobber`.
7. **WebUI "Suspicious Mounts" blok kosong.** Tidak ada sus mount adalah hasil yang
   benar (kernel umount + NoMount), bukan kegagalan - sekarang tertulis `None`.

Dua gerbang audit baru supaya tiga kelas kesalahan di atas tidak bisa masuk lagi diam-diam:
setiap toggle wajib punya elemen `id` di `index.html` dan entri di daftar `configs` di
`script.js` (kecuali 3 text field), dan semua JavaScript WebUI harus lolos `node --check`
(sebelumnya tidak ada satu pun pemeriksaan JS - `script.js` rusak baru ketahuan di perangkat).

### 8.4 Diperiksa, bersih

`bash -n` + `shellcheck -S error` semua script modul; `actionlint` untuk workflow;
`node --check` untuk `script.js`, `assets/kernelsu.js`, `assets/mwc.js`; `prettier --check`;
`module.prop` ↔ `update.json` sinkron dan keduanya menunjuk `dlagia/BRENE`;
41 toggle punya switch WebUI kecuali 3 text field yang memang ditangani terpisah;
seluruh langkah job `audit` dijalankan lokal dan lolos.

### 8.5 Issues

Issues di fork ini **dimatikan**, jadi yang ditinjau adalah 5 issue terbuka di upstream:

| Upstream | Isi                                                          | Relevan untuk fork ini?                                             |
| -------- | ------------------------------------------------------------ | ------------------------------------------------------------------- |
| #25      | USB debugging mati saat spoof properti sistem aktif          | **Ya, dan default menyala** - lihat catatan di bawah                |
| #57      | Toggle Wireless Debugging bentrok dengan modul pengubah port | Tidak, `config_wireless_debugging=0`                                |
| #43      | Path hiding LineageOS                                        | Tidak, `config_hide_lineage_strings=0` dan ROM-nya bukan Lineage    |
| #58      | Hunter 6.72 mendeteksi "Unknown Exec Item From ISO"          | Tidak ada tindakan di sisi modul; deteksi aplikasi, bukan bug BRENE |
| #20      | Dukungan multi-bahasa WebUI                                  | Permintaan fitur upstream                                           |

**Catatan #25 (perilaku bawaan, bukan bug).** `config_spoof_system_properties=1` (default)
memanggil `spoof_system_properties`, yang menyetel `ro.adb.secure=1`, `ro.secure=1`,
`persist.sys.usb.config=mtp`, `init.svc.adbd=stopped`, dan menghapus
`service.adb.root`/`service.adb.tcp.port`. Efeknya ADB bisa ikut mati. Kalau ADB
diperlukan: nyalakan `config_usb_debugging` dari WebUI, atau matikan sementara
`Spoof System Properties` lalu reboot. Tidak diubah di fork - itu inti gunanya modul ini.
