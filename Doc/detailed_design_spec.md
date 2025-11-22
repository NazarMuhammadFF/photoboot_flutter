# Detailed Design Specification & Requirements

# Photo Booth V2

Dokumen ini berisi spesifikasi teknis mendalam mengenai layout antarmuka, sistem grid, spesifikasi template, dan logika pencetakan.

---

## 1. UI/UX Layout Design

### 1.1 User App (Android Tablet/Mobile)

Target Device: Samsung Galaxy Tab S series / iPad (Landscape Mode preferred) atau Smartphone (Portrait).
**Mode: Kiosk (Full Screen, No Status Bar)**

#### A. Idle / Attract Screen

- **Background**: Video looping atau Slideshow hasil foto menarik.
- **Element**: Tombol besar "TOUCH TO START" berkedip.
- **Posisi**: Center Middle.

#### B. Grid Selection Screen

- **Layout**: Grid View (2 kolom x 2 baris).
- **Card Item**: Menampilkan _thumbnail_ layout (misal: ikon strip panjang, ikon kotak 2x2).
- **Label**: "Strip (1x3)", "Postcard (2x2)", dll.

#### C. Template Selection Screen

- **Layout**: Horizontal Scroll (Carousel).
- **Preview**: Menampilkan template kosong sesuai Grid yang dipilih sebelumnya.

#### D. Live Camera (Capture Screen)

- **View**:
  - **Top/Center**: Live Preview Kamera (Mirroring: ON).
  - **Overlay**: Frame template (transparan) menumpuk di atas preview (Opsional, bisa dimatikan agar user fokus pose).
  - **Center**: Countdown Timer Besar (3.. 2.. 1..).
- **Bottom Bar**:
  - Indikator slot foto (misal: Bulatan 1/3, 2/3, 3/3).
  - Tombol Batal (Kecil di pojok kiri).

#### E. Preview & Editing

- **Layout**: Split Screen.
  - **Kiri**: Hasil Foto Final (Preview Grid).
  - **Kanan**: Panel Sticker (Drag & Drop).
- **Action**: "Retake" (Ulang semua) atau "Print & Finish".

---

## 2. Grid System & Template Specifications

Sistem menggunakan standar cetak **300 DPI (Dots Per Inch)** untuk kualitas foto terbaik.

### 2.1 Base Paper Sizes (Canvas)

Ukuran kertas fisik yang umum digunakan printer foto (DNP/Canon Selphy/Epson).

| Tipe Kertas       | Inci       | Milimeter | Resolusi (300 DPI) | Rasio  |
| :---------------- | :--------- | :-------- | :----------------- | :----- |
| **4R (Standard)** | 4 x 6      | 102 x 152 | **1200 x 1800 px** | 2:3    |
| **Photo Strip**   | 2 x 6      | 51 x 152  | **600 x 1800 px**  | 1:3    |
| **A4 (Office)**   | 8.3 x 11.7 | 210 x 297 | **2480 x 3508 px** | ~1:1.4 |

### 2.2 Grid Configurations (Koordinat Pixel)

Semua koordinat dihitung berdasarkan **Canvas 4R (1200 x 1800 px)** atau **Strip (600 x 1800 px)**.

#### A. Tipe: Photo Strip (1x3)

_Biasanya dicetak 2 strip dalam 1 kertas 4R (Twin Strip)._

- **Canvas**: 600 x 1800 px.
- **Orientation**: Vertical.
- **Photo Slots**: 3 Foto.
- **Ukuran Foto**: ~500 x 400 px (Landscape crop) atau menyesuaikan desain.
- **Space Bawah**: Tersedia ~300px untuk Logo/Branding.

#### B. Tipe: Photo Strip (1x4)

- **Canvas**: 600 x 1800 px.
- **Photo Slots**: 4 Foto.
- **Ukuran Foto**: Lebih kecil, bentuk Square atau Portrait.

#### C. Tipe: Postcard Collage (2x2)

- **Canvas**: 1200 x 1800 px (Portrait) atau 1800 x 1200 px (Landscape).
- **Photo Slots**: 4 Foto.
- **Layout**: Grid 2 kolom, 2 baris.

#### D. Tipe: Postcard Collage (2x3)

- **Canvas**: 1800 x 1200 px (Landscape).
- **Photo Slots**: 6 Foto.

### 2.3 Template Asset Requirements (Untuk Desainer)

Agar template pas dengan sistem, desainer harus mengikuti aturan ini:

1. **Format**: PNG (24-bit atau 32-bit).
2. **Transparency**: Area tempat foto muncul harus **Transparan (Alpha Channel)**.
3. **Resolution**: Harus sesuai ukuran Canvas (misal 1200x1800 px).
4. **Overlay**: Template berada di layer paling atas (Z-Index: 10), Foto user di layer bawah (Z-Index: 0).

---

## 3. Printing Logic & Paper Adaptation

Tantangan utama adalah menyesuaikan ukuran canvas digital ke kertas fisik yang tersedia di printer.

### 3.1 Skenario 1: Printer Foto Khusus (DNP / Canon Selphy CP1300)

Printer ini biasanya menggunakan kertas roll atau kaset ukuran 4R fix.

- **Jika User memilih 4R (Postcard)**:
  - Print langsung 1:1.
- **Jika User memilih Strip (2x6)**:
  - Aplikasi harus melakukan **"Double Up"**.
  - Canvas Strip (600x1800) diduplikasi ke samping.
  - Hasil akhir canvas cetak: 1200x1800 px (berisi 2 strip identik).
  - Printer akan mencetak 4R, lalu user memotongnya manual (atau printer DNP tipe tertentu bisa auto-cut).

### 3.2 Skenario 2: Printer Inkjet Standar (Epson L Series - A4)

Kertas A4 jauh lebih besar dari 4R. Tidak boleh mencetak 1 foto kecil di tengah kertas A4 (boros).

- **Logic**: "N-Up Printing" (Tiling).
- **A4 Canvas**: 2480 x 3508 px.
- **Fit**:
  - Bisa memuat **4 lembar ukuran 4R** dalam 1 kertas A4.
  - Atau memuat **8 lembar ukuran Strip** dalam 1 kertas A4.
- **Crop Marks**: Aplikasi harus otomatis menambahkan garis potong (garis putus-putus tipis) di sela-sela gambar untuk memudahkan pemotongan manual.

---

## 4. Operator Dashboard (Windows) Layout

### 4.1 Sidebar Navigation

- Dashboard (Home)
- Session History (List user yang sudah foto)
- Configuration (Grid, Template, Printer)
- File Manager (Local / Cloud status)

### 4.2 Configuration Panel (Grid & Template)

Fitur ini memungkinkan Operator menambah layout baru tanpa coding ulang.

- **Add New Grid**:
  - Input Nama: "Special Event 1x1"
  - Input Canvas Size: Width x Height
  - **Grid Editor**:
    - Klik "Add Slot".
    - Drag & Resize kotak slot foto di layar (seperti Canva sederhana).
    - Simpan koordinat (x, y, w, h) ke dalam JSON.
- **Upload Template**:
  - Upload file PNG overlay.
  - Assign ke Grid tertentu.

---

## 5. Data Structure (JSON Representation)

Setiap Grid disimpan dalam format JSON agar fleksibel.

```json
{
  "id": "strip_1x3",
  "name": "Classic Strip",
  "canvas_width": 600,
  "canvas_height": 1800,
  "print_behavior": "duplicate_on_4r", // Opsi: normal, duplicate_on_4r, fit_to_a4
  "slots": [
    { "id": 1, "x": 50, "y": 50, "width": 500, "height": 400, "rotation": 0 },
    { "id": 2, "x": 50, "y": 470, "width": 500, "height": 400, "rotation": 0 },
    { "id": 3, "x": 50, "y": 890, "width": 500, "height": 400, "rotation": 0 }
  ],
  "overlay_image": "assets/templates/strip_overlay_01.png"
}
```

---

## 6. Kebutuhan Tambahan (Expanded Requirements)

1.  **Camera Aspect Ratio Handling**:

    - Kamera biasanya 4:3 atau 16:9.
    - Slot foto mungkin berbentuk kotak (1:1) atau aneh.
    - **Solusi**: Implementasi `Center Crop` otomatis pada preview dan hasil capture agar tidak gepeng (stretched).

2.  **Lighting & Flash**:

    - Jika menggunakan tablet, layar bisa menjadi "Flash" dengan berubah menjadi putih terang sesaat sebelum capture.

3.  **Timeout System**:

    - Jika User diam di halaman "Select Grid" selama 60 detik -> Kembali ke Home (Reset).
    - Mencegah antrian macet karena user sebelumnya pergi tanpa menyelesaikan sesi.

4.  **Offline Mode Robustness**:
    - Jika internet mati (gagal upload Google Drive), file disimpan di "Pending Queue" lokal.
    - Operator bisa klik "Retry Upload All" saat internet kembali.
