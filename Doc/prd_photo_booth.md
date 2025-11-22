# Product Requirements Document (PRD)

# Photo Booth Application

## 1. Overview

Aplikasi Photo Booth ini dirancang untuk memberikan pengalaman foto yang cepat, mudah, dan intuitif bagi pengguna (User), dengan sistem kontrol penuh di sisi Operator. Aplikasi berjalan pada dua perangkat yang berbeda:

- **User App**: Android (Tablet/Smartphone)
- **Operator App**: Windows (Desktop/Laptop)

Menggunakan Flutter sebagai basis pengembangan dengan komunikasi antar perangkat melalui jaringan lokal (LAN/WiFi).

Tujuan utama:

- Memberikan pengalaman foto yang seamless bagi User di perangkat Android.
- Memberikan kontrol penuh bagi Operator untuk manajemen sesi, perangkat, dan hasil foto dari Windows.
- Memastikan integrasi yang stabil antara perangkat, kamera, printer, dan penyimpanan cloud.
- Komunikasi real-time antara User (Android) dan Operator (Windows).

---

## 2. User Roles

### 2.1 User (Pengguna)

Role utama yang menggunakan Photo Booth dan mengikuti alur standar:

- Memulai sesi foto.
- Memilih grid dan template.
- Mengambil foto sesuai jumlah slot.
- Meninjau dan menyetujui hasil.
- Menambah stiker pada hasil akhir.
- Mengunduh atau mencetak hasil foto.

### 2.2 Operator

Operator mengelola pengaturan sistem dan memonitor setiap sesi:

- Mengatur grid dan template yang tersedia.
- Mengatur sticker yang tersedia.
- Mengelola kamera (pilih kamera, cek status koneksi).
- Melihat preview hasil sebelum dicetak.
- Menyetujui permintaan cetak.
- Mengatur seluruh konfigurasi printer.
- Mengatur lokasi penyimpanan file (local/cloud).
- Melihat status dan aktivitas sesi User.
- Force end sesi bila diperlukan.

---

## 3. User Flow

### 3.1 Home

- Tampilkan tombol **Start**.
- Tampilkan tombol **Operator** (akses via password).

### 3.2 Pilih Grid

User memilih layout seperti:

- 1x3
- 2x2
- 2x3
  Grid yang muncul sudah ditentukan Operator.

### 3.3 Pilih Template

User memilih desain template yang tersedia.

### 3.4 Mode Kamera

- Kamera fullscreen.
- Timer otomatis 3 detik.
- Preview kecil muncul setiap selesai jepret.
- User dapat **Retake** untuk setiap slot.
- Setelah seluruh slot terisi, lanjut otomatis.

### 3.5 Editing Ringan

- User dapat menambahkan stiker.
- Tidak ada pengaturan lanjutan lain.

### 3.6 Konfirmasi Hasil

User memilih “Lanjutkan hasil”.

### 3.7 Output

User memilih:

- **Cetak** → muncul loading, menunggu Operator approve.
- **Download** → muncul QR menuju file hasil.

### 3.8 Selesai

User kembali ke Home.

---

## 4. Operator Flow

### 4.1 Login Operator

- Password protected.

### 4.2 Dashboard Operator

Menampilkan:

- Daftar sesi aktif.
- Status kamera (connected / disconnected).
- Preview hasil dari User.

### 4.3 Fitur Operator

1. **Mengatur Grid yang tampil di User**.
2. **Mengatur Template yang tampil di User**.
3. **Mengatur Sticker** (tambah/hapus).
4. **Memilih Kamera aktif**.
5. **Melihat indikator kamera aktif / nonaktif**.
6. **Melihat preview hasil User sebelum cetak**.
7. **Approve Print**.
8. **Mengatur konfigurasi Printer**.
9. **Mengatur lokasi penyimpanan file** (local / Google Drive / Cloud lain).
10. **Melihat status sesi** (active / completed / forced end).
11. **Force end Sesi**.

---

## 5. Sistem & Integrasi Teknis

### 5.1 Flutter Multi-Platform Architecture

- **Aplikasi User**: Android (Tablet/Smartphone)
  - Build target: Android APK/AAB
  - Interface touch-optimized
  - Portrait/Landscape mode support
- **Aplikasi Operator**: Windows (Desktop/Laptop)
  - Build target: Windows executable
  - Mouse/Keyboard interface
  - Multi-monitor support
- **Koneksi antar perangkat**:
  - WebSocket/HTTP untuk komunikasi real-time
  - Jaringan lokal (WiFi/LAN)
  - Auto-discovery perangkat di jaringan yang sama
  - Fallback: Manual IP entry

### 5.2 Kamera

- Kamera harus mendukung akses USB atau IP.
- Operator dapat mengganti kamera dari panel.

### 5.3 Printer

- Semua pengaturan printer disimpan dan dikelola Operator.
- User tidak melihat pengaturan printer.
- Hasil cetak hanya berjalan setelah Operator approve.

### 5.4 Penyimpanan File

Operator dapat memilih mode:

- Local Directory.
- Google Drive (melalui API dan kredensial).
- Cloud Storage lain.

Output User berupa QR yang menuju lokasi file tersebut.

---

## 6. File Struktur yang Dibutuhkan untuk Pengembangan (Pendukung MCP / AI Builder)

1. **PRD (dokumen ini)**.
2. **Wireframe UI / Mockup**.
3. **Dokumen teknis integrasi kamera**.
4. **Dokumen teknis integrasi printer**.
5. **Dokumen teknis integrasi cloud storage**.
6. **Flowchart aplikasi**.
7. **Konfigurasi environment**.
8. **Daftar asset** (template, grid, sticker).

---

## 7. Non-Functional Requirement

- Performa kamera stabil tanpa lag.
- Transmisi file antar perangkat cepat.
- Waktu cetak minimal.
- Sistem tetap berjalan meski koneksi jaringan melambat.
- UI responsif untuk perangkat sentuh.

---

## 8. Kesimpulan

Dokumen ini menjadi dasar pembangunan aplikasi Photo Booth berbasis Flutter dengan dua sisi operasional (User dan Operator). Seluruh kebutuhan teknis, alur desain, fitur, dan integrasi ditetapkan agar aplikasi berjalan stabil, efisien, dan mudah digunakan.
