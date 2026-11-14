# 🎨 SegarScan — Design System & Visual Guidelines

> **Prinsip Utama:** *Clean, Purposeful, and Production-Ready.*  
> Panduan ini menetapkan aturan tata letak, hierarki konten, dan standar estetika agar seluruh layar SegarScan memiliki bahasa visual yang selaras dan matang.

---

## 1. Aturan Tata Letak & Spacing (8pt Grid System)

Untuk menjaga keselarasan antar-layar, semua ukuran margin, padding, dan jarak antar-elemen wajib mengikuti skala:

| Elemen | Token / Nilai | Catatan Penggunaan |
|---|---|---|
| **Screen Horizontal Padding** | `20 px` | Jarak konsisten kiri & kanan pada seluruh halaman (`ListView(padding: 20)`). |
| **Section Gap** | `24 px` s.d. `28 px` | Jarak vertikal antar-kelompok konten/section. |
| **Card Internal Padding** | `16 px` s.d. `20 px` | Ruang bernapas dalam kontainer kartu. |
| **Item Internal Gap** | `8 px`, `12 px`, `16 px` | Jarak antar-kartu kecil atau elemen baris. |

---

## 2. Aturan Kartu & Elevasi (Clean Surface Rules)

*Hindari drop-shadow tebal khas template AI.* Gunakan gaya permukaan modern:
* **Background Utama:** `#F8FAF8` (Putih kehijauan sangat lembut, natural).
* **Card Surface:** `#FFFFFF` (Putih murni).
* **Border Garis Halus:** `1.0 px` solid dengan warna `#EDF2EE` atau `#E8ECE8`.
* **Elevasi Bayangan:** Maksimal `blurRadius: 10`, `offset: (0, 3)`, dengan warna `Colors.black.withValues(alpha: 0.02)`.
* **Hierarki Border Radius:**
  * **Kartu Kontainer Utama:** `BorderRadius.circular(20)`
  * **Status Badges & Chips:** `BorderRadius.circular(24)` (Kapsul/Pill)
  * **Tombol Aksi (Buttons):** `BorderRadius.circular(14)`
  * **Thumbnail Foto / Gambar:** `BorderRadius.circular(14)`
  * **Progress Bar:** `BorderRadius.circular(8)`

---

## 3. Palet Warna & Semantic Tokens

### 🌿 Brand & Primary
* `AppColors.primaryGreen` (`#43A047` / `#2E7D32`): Tombol aksi utama, ikon aktif, aksen penting.
* `AppColors.primaryLight` (`#E8F5E9`): Latar belakang ikon lingkaran, badge lembut, aksen container.
* `AppColors.primaryDark` (`#1B5E20`): Teks aksen hijau gelap untuk kontras tinggi.

### 🍎 Status Mutu Buah (WCAG AA Compliant)
| Status | Warna Utama | Background Lembut | Ikon | Label Lengkap |
|---|---|---|---|---|
| 🟢 **Bagus** | `#2E7D32` | `#E8F5E9` | `Icons.check_circle_rounded` | "Kualitas Bagus (Segar)" |
| 🟡 **Cukup** | `#F57F17` | `#FFF8E1` | `Icons.info_rounded` | "Kualitas Cukup (Konsumsi Segera)" |
| 🔴 **Busuk** | `#C62828` | `#FFEBEE` | `Icons.cancel_rounded` | "Kualitas Busuk (Tidak Layak)" |

### 🖋️ Tipografi & Warna Teks
* **Teks Utama (`AppColors.textPrimary`):** `#1C251D` (Slate green sangat gelap, lebih berkarakter daripada hitam pekat).
* **Teks Sekunder (`AppColors.textSecondary`):** `#4D5C4F` (Abu-abu kehijauan netral).
* **Teks Bantuan/Muted (`AppColors.textMuted`):** `#7D8D7F` (Keterangan waktu, label kecil).

---

## 4. Standar Hierarki Tipografi

* **App Title / Brand:** Poppins Bold 20 sp
* **Section Heading:** Poppins Semi-Bold 17 sp (selalu diberi `SizedBox(height: 12)` ke kontennya)
* **Card Title / Fruit Name:** Poppins Semi-Bold 15-16 sp
* **Body Regular:** Inter Medium 13-14 sp (height 1.4 untuk kenyamanan membaca)
* **Caption / Timestamp / Hint:** Inter Regular 11-12 sp

---

## 5. Standar Konten Halaman Beranda (Home Screen)

Agar Beranda terasa lengkap, fungsional, dan berstandar aplikasi komersial:
1. **Header Bar:**
   * Logo SegarScan + chip status sistem (misal: `🟢 Siap Pindai` atau mode inferensi aktif).
   * Tombol Bantuan Pemotretan & Pengaturan.
2. **Hero Action Card:**
   * Banner segar dengan pesan ringkas, tombol cepat Kamera & Galeri, dan indikator buah yang didukung.
3. **Executive KPI Dashboard (Metrik Kunci):**
   * Total Buah, Rasio Segar (%), Perlu Dipilah, dan Kecepatan Rata-rata inferensi.
4. **Katalog Buah yang Didukung (Supported Fruit Chips/List):**
   * Memberikan kejelasan langsung kepada pengguna jenis buah apa saja yang dapat dikenali AI (Apel, Jeruk, Pisang, Mangga, Tomat) beserta status kemampuannya.
5. **Panduan Tips Pemotretan Cepat:**
   * Kartu interaktif tips pemotretan (Pencahayaan, Sudut 1 Buah, Background Polos) untuk memaksimalkan akurasi Computer Vision.
6. **Aktivitas Sortir Terbaru:**
   * Menampilkan hingga 4 riwayat terakhir lengkap dengan thumbnail, confidence %, dan status badge.
   * Empty state rapi jika belum pernah memindai buah.

---

## 6. Standar Penanganan 4 State
Setiap layar wajib mengimplementasikan 4 kondisi ini secara seragam:
1. **Loading State:** Circular loader halus dengan pesan progres yang jelas dalam Bahasa Indonesia.
2. **Success State:** Kartu-kartu terstruktur rapi sesuai grid.
3. **Empty State:** Menggunakan widget `EmptyStateView` dengan ikon bulat berlatar hijau muda + teks panduan + tombol aksi.
4. **Error State:** Banner / snackbar merah lembut dengan tombol *Coba Lagi*.
