# 🗺️ SegarScan — Development Roadmap & Progress Tracker

> **Panduan Vibe Coding:** Gunakan dokumen ini untuk memantau progress pengerjaan. Centang `[x]` setiap kali satu item selesai. Jangan loncat ke fase berikutnya sebelum fase fondasi stabil.

---

## 📊 Status Ringkasan

- **Fase Saat Ini:** Fase 6 & 7 — Integrasi & Siap Demo
- **Target MVP:** ✅ Arsitektur Clean, State Management Riverpod, Mock & API Service, SQLite, Charts, dan UI telah selesai diimplementasikan!
- **Total Fitur MVP:** 6 modul utama (Kamera/Galeri, Preprocessing, Inferensi Mock/API, Hasil, Riwayat Lokal, Statistik Interaktif)

---

## 🎯 Fase 1: Inisialisasi & Arsitektur Fondasi

- [x] **1.1 Setup Proyek Mobile (Flutter)**
  - [x] Generate Flutter project: `segarscan`
  - [x] Konfigurasi `pubspec.yaml` dengan dependency inti (`flutter_riverpod`, `image_picker`, `sqflite`, `dio`, `fl_chart`, `intl`, `google_fonts`)
  - [x] Setup file permission kamera, storage, & cleartext traffic di `AndroidManifest.xml`
- [x] **1.2 Desain Sistem & Tema**
  - [x] Buat `lib/core/constants/app_colors.dart` (Primary Green, Status Badges)
  - [x] Buat `lib/core/theme/app_theme.dart` (Material 3 ThemeData)
  - [x] Buat `lib/core/constants/fruit_constants.dart` (Label buah & kualitas)
- [x] **1.3 Struktur Folder & Abstraksi Data**
  - [x] Susun folder arsitektur Clean/Layered (`core/`, `data/`, `providers/`, `presentation/`)
  - [x] Buat model DTO `PredictionResult`, `FruitQuality`, `ScanHistoryItem`
  - [x] Buat kontrak interface `IClassifierService`

---

## 🚀 Fase 2: Mock Inferensi & Pipeline Pengolahan Gambar

- [x] **2.1 Pipeline Gambar (Preprocessing)**
  - [x] Helper kompresi dan resize citra (maks 1024px, quality 85)
- [x] **2.2 Mock Classifier Service**
  - [x] Implementasi `MockClassifierService` dengan delay buatan (800ms)
  - [x] Kembalikan variasi realistis (Apel/Jeruk/Pisang/Mangga/Tomat - Bagus/Cukup/Busuk)
  - [x] Sediakan toggle mudah di dependency injection antara Mock dan API nyata

---

## 📱 Fase 3: Layar Inti (Scan & Hasil Klasifikasi)

- [x] **3.1 Layar Scan (`presentation/screens/scan/`)**
  - [x] Widget panduan framing tengah (kotak fokus bantu)
  - [x] Tombol kamera dan tombol pilih dari galeri
  - [x] Transisi elegan ke overlay loading ("Sedang menganalisis kualitas buah...")
- [x] **3.2 Layar Hasil (`presentation/screens/result/`)**
  - [x] Preview foto buah yang dianalisis
  - [x] Nama buah & `QualityBadge` (🟢 Bagus, 🟡 Cukup, 🔴 Busuk)
  - [x] Nilai confidence dalam persentase + progress bar animasi
  - [x] Distribusi probabilitas (Bagus %, Cukup %, Busuk %)
  - [x] Rekomendasi tindakan (Layak jual, Pisahkan, dll.)
  - [x] Tombol **Simpan ke Riwayat** dan tombol **Scan Ulang**

---

## 💾 Fase 4: Database Lokal & Riwayat Scan

- [x] **4.1 Database Helper (`data/local/database_helper.dart`)**
  - [x] Inisialisasi SQLite database `segarscan.db`
  - [x] Pembuatan tabel `scan_history` sesuai spesifikasi
  - [x] CRUD methods: `insertScan()`, `getAllHistory()`, `deleteScan()`, `clearAll()`
  - [x] Method agregasi statistik: `getQualityCounts()`, `getFruitTypeCounts()`, `getTotalScans()`
- [x] **4.2 Layar Riwayat (`presentation/screens/history/`)**
  - [x] Listview riwayat dengan thumbnail foto, nama buah, badge, dan tanggal
  - [x] Filter berdasarkan status mutu (Semua, Bagus, Cukup, Busuk)
  - [x] Fitur hapus item (swipe-to-dismiss) dan dialog konfirmasi hapus semua
  - [x] Empty state ramah pengguna ("Belum ada riwayat sortir")
- [x] **4.3 Layar Detail Riwayat (`presentation/screens/history/detail/`)**
  - [x] Tampilan lengkap hasil scan tersimpan beserta waktu inferensi dan waktu simpan

---

## 📊 Fase 5: Beranda & Modul Statistik

- [x] **5.1 Layar Beranda (`presentation/screens/home/`)**
  - [x] Hero banner sapaan dan tombol pintas **Kamera / Galeri**
  - [x] Kartu ringkasan cepat (total scan, jumlah bagus, cukup, busuk)
  - [x] Daftar aktivitas terbaru dengan thumbnail
- [x] **5.2 Layar Statistik (`presentation/screens/statistics/`)**
  - [x] Diagram lingkaran (Pie Chart) perbandingan Bagus / Cukup / Busuk via `fl_chart`
  - [x] Distribusi per jenis buah dengan progress bar
  - [x] Metrik ringkas: total buah tersortir & rasio mutu bagus
  - [x] Empty state jika belum ada data scan

---

## ⚙️ Fase 6: Pengaturan & Integrasi API Nyata (Tim CV)

- [x] **6.1 Layar Pengaturan (`presentation/screens/settings/`)**
  - [x] Toggle mode inferensi: **Mock Mode (Offline)** vs **API Mode**
  - [x] Input Base URL API backend (`http://...:8000`)
  - [x] Halaman **Tentang Aplikasi** (informasi tubes, versi, daftar buah)
- [x] **6.2 Klien API Nyata (`data/services/api_classifier_service.dart`)**
  - [x] Integrasi `Dio` untuk upload multipart/form-data ke `POST /predict`
  - [x] Penanganan timeout jaringan, koneksi gagal, dan validasi JSON


---

## 🧪 Fase 7: Pengujian, Polishing & Demo Prep

- [ ] **7.1 Unit & Widget Testing**
  - [ ] Test DTO JSON parser (sukses dan format salah)
  - [ ] Test query agregasi SQLite
- [ ] **7.2 Robustness & Error State Check**
  - [ ] Test kamera tanpa izin ➡️ apakah UX tetap nyaman?
  - [ ] Test offline/server down ➡️ apakah pesan error berbahasa Indonesia informatif?
  - [ ] Test foto buram/bukan buah ➡️ penanganan confidence rendah
- [ ] **7.3 Build APK & Demo Preparation**
  - [ ] Build release APK: `flutter build apk --release`
  - [ ] Skenario demo live (siapkan buah sampel & mode mock cadangan jika Wi-Fi bermasalah)
