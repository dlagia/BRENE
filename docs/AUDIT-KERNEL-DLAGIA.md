# Audit BRENE untuk kernel dlagia/test (rosemary 4.14)

Tanggal audit: 2026-09-21.
Yang diaudit: `dlagia/BRENE` @ `b255fec` (identik dengan upstream `rrr333nnn333/BRENE` HEAD)
terhadap kernel `dlagia/test` revisi ke-42c (run build `35499235046`, sukses).

## 1. Yang dipakai kernel ini

| Komponen | Nilai | Sumber |
| --- | --- | --- |
| Kernel | Xiaomi rosemary, 4.14, NON-GKI | `KERNEL_PIN=602782da` |
| KernelSU | ReSukiSU `6d18926a`, version code **35158** | log build: `ReSukiSU 35158` |
| SuSFS | **v2.3.0**, varian **NON-GKI** | patch JackA1ltman `ac370f5d` |
| Fitur SuSFS aktif | 9 (lihat tabel di bawah) | `out/.config` di log build |

## 2. Gerbang kompatibilitas BRENE

`module/customize.sh` menolak install kalau salah satu tidak terpenuhi:

| Syarat | Kernel ini | Status |
| --- | --- | --- |
| `$KSU` terisi (KernelSU atau fork) | ReSukiSU | ✅ |
| `$ARCH` = arm64 | arm64 | ✅ |
| `KSU_KERNEL_VER_CODE` ≥ 32336 | 35158 | ✅ (margin 2822) |
| `susfs show version` diawali `v2` | v2.3.0 | ✅ |
| `/data/adb/ksu/bin` ada | dibuat ksud | ✅ |

**Catatan penting soal 35158.** Angka itu dihitung `kernel/Kbuild` ReSukiSU sebagai
`30000 + $(git rev-list --count HEAD) + 700`. Artinya version code bergantung pada
**riwayat git** klon ReSukiSU saat kernel dibangun, bukan pada isi kodenya. Kalau suatu
saat klon ReSukiSU di workflow berubah jadi dangkal (`--depth 1`) dan Kbuild gagal
meng-`unshallow`, version code jatuh ke ±30701 dan **BRENE menolak terpasang** dengan
pesan "Unsupported KernelSU kernel version". `kernel/setup.sh` yang dipakai sekarang
melakukan klon penuh, jadi aman - tapi ini yang pertama dicek kalau install tiba-tiba
ditolak setelah menaikkan `KSU_PIN`.

## 3. Fitur SuSFS: yang dibutuhkan BRENE vs yang ada di kernel

| Fitur kernel | Ada? | Dipakai BRENE untuk |
| --- | --- | --- |
| `CONFIG_KSU_SUSFS_SUS_PATH` | ✅ | sembunyikan path non-standar di `/sdcard`, `/data/local/tmp`, jejak recovery |
| `CONFIG_KSU_SUSFS_SUS_MOUNT` | ✅ | `hide_sus_mnts_for_non_su_procs` |
| `CONFIG_KSU_SUSFS_SUS_KSTAT` | ✅ | `spoof_hosts`, `fix_data_local_tmp_inconsistencies` |
| `CONFIG_KSU_SUSFS_SUS_MAP` | ✅ | `hide_addon_d`, `hide_framework_res_apk` |
| `CONFIG_KSU_SUSFS_SPOOF_UNAME` | ✅ | `spoof_uname`, `custom_spoof_uname` |
| `CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG` | ✅ | `spoof_cmdline_or_bootconfig` (default mati) |
| `CONFIG_KSU_SUSFS_OPEN_REDIRECT` | ✅ | `spoof_libstagefright`, `hide_lineage_strings` (default mati) |
| `CONFIG_KSU_SUSFS_ENABLE_LOG` | ✅ | `enable_log` |
| `CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS` | ✅ | tidak dipanggil modul, murni kernel |

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

| Panggilan BRENE | Ada di ReSukiSU |
| --- | --- |
| `ksud module config set override.description` | ✅ |
| `ksud feature set su_compat\|kernel_umount\|selinux_hide` + `feature save` | ✅ |
| `ksud kernel umount add -f 2 <mnt>` | ✅ |
| `ksud kernel notify-module-mounted` | ✅ |
| `ksud boot-info current-kmi` | ✅ (hanya dipakai di jalur GKI, tidak kena kernel ini) |
| `resetprop` di `PATH` | ✅ `/data/adb/ksu/bin/resetprop` |
| `busybox` untuk `brene_clone_perm` | ✅ `/data/adb/ksu/bin/busybox` |

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
   yang **aktif secara default**. Di `post-fs-data` ia jalan *sebelum* script modul
   (aman, BRENE menimpa belakangan), tapi di `boot-completed` ia jalan *sesudah* script
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
  (`CMD_SUSFS_ADD_TRY_UMOUNT` ditandai *deprecated*), jadi tidak pernah resolve di
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
