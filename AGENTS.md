# 🥑 SegarScan — Vibe Coding Playbook & Agent Guide

> **Misi Proyek:** Membangun aplikasi mobile sortir mutu buah berbasis Computer Vision (*SegarScan*) secara cepat, terarah, dan berkualitas tinggi (*Vibe Coding with Engineering Rigor*).  
> **Dokumen Acuan:** [SegarScan_Kebutuhan_Aplikasi.md](file:///d:/project/SegarScan/SegarScan_Kebutuhan_Aplikasi.md)  
> **Target Pengguna:** Petani/pedagang buah, konsumen, dan demo penguji mata kuliah Computer Vision.

---

## 1. Filosofi Vibe Coding di SegarScan

*Vibe coding* bukan berarti menulis kode tanpa aturan atau menghasilkan *spaghetti code*. Di SegarScan, vibe coding berarti:
1. **Move Fast, Stay Modular:** Bangun fitur dengan cepat menggunakan pola arsitektur berlapis (Clean/Feature-first). Ubah implementasi tanpa merusak komponen lain.
2. **Mock-First Always:** Jangan pernah menunggu model CV dari rekan tim selesai. Bangun seluruh alur UI, database, dan state dengan `MockClassifierService` terlebih dahulu.
3. **Aesthetic & Polished UX:** Antarmuka harus terasa modern, segar (tema hijau segar), responsif, dan ramah pengguna dengan penanganan *loading*, *empty state*, dan *error state* yang elegan.
4. **Single Source of Truth:** Semua kontrak data, skema database, dan label harus merujuk pada kesepakatan di `SegarScan_Kebutuhan_Aplikasi.md`.

---

## 2. Pemetaan Skill AI (Agent Skills Playbook)

Gunakan skill-skill berikut sesuai fase pengerjaan tugas:

| Skill | Kapan Digunakan di SegarScan | Panduan Singkat |
|---|---|---|
| `spec-driven-development` | Sebelum membuat modul baru (Scan, Result, History, Stats) | Pecah kebutuhan dari SRS menjadi spesifikasi interface & state yang jelas sebelum menulis kode UI. |
| `api-and-interface-design` | Merancang kontrak API `POST /predict` & abstraksi `IClassifierService` | Pastikan kontrak payload, respon sukses/gagal, dan model DTO konsisten dan fleksibel. |
| `frontend-ui-engineering` | Membangun screen, widget, animasi, dan layout | Terapkan Material 3, tema warna segar, accessibility, responsive layout, dan feedback visual interaktif. |
| `incremental-implementation` | Mengerjakan fitur kompleks (kamera + kompresi + inferensi) | Bagi ke langkah-langkah kecil yang dapat di-run dan diuji per tahap, hindari *big-bang code dump*. |
| `test-driven-development` | Validasi parser JSON, perhitungan statistik, kalkulasi akurasi | Buat unit test untuk DTO parser, kalkulasi ringkasan riwayat, dan query filter SQLite. |
| `code-review-and-quality` | Sebelum menyelesaikan milestone fitur | Evaluasi kode terhadap clean code, null safety, memory leak pada controller kamera/stream. |
| `code-simplification` | Refactoring widget pohon yang terlalu dalam | Ekstrak reusable widgets (`QualityBadge`, `ConfidenceBar`, `FruitCard`) agar kode tetap bersih dan mudah dibaca. |
| `debugging-and-error-recovery` | Mengatasi kendala izin kamera, timeout HTTP, crash SQLite | Gunakan pendekatan akar masalah (root cause analysis) sistematis, bukan tebak-tebakan. |
| `constraint-driven-development` | Menjaga NFR (kinerja & usability) | Pantau NFR-01 (waktu scan < 5s) dan NFR-03 (alur maks 3 ketukan). |
| `git-workflow-and-versioning` | Melakukan commit dan branching | Gunakan format Conventional Commits (`feat:`, `fix:`, `refactor:`, `docs:`). |

---

## 3. Arsitektur & Pola Desain (Clean Layered Pattern)

Gunakan pola arsitektur berlapis yang memisahkan **Presentation**, **Domain/State**, dan **Data**:

```
lib/
├── core/
│   ├── constants/          # AppColors, ApiEndpoints, FruitLabels
│   ├── theme/              # AppTheme (Light & Dark), Typography
│   └── utils/              # ImageCompressor, DateFormatter, DialogHelper
├── data/
│   ├── models/             # PredictionResult, ScanHistoryItem, ApiResponse
│   ├── local/              # DatabaseHelper (SQLite/sqflite)
│   └── services/           # classifier_service.dart
│       ├── classifier_interface.dart  # IClassifierService
│       ├── mock_classifier_service.dart # Untuk development & demo offline
│       ├── api_classifier_service.dart  # HTTP ke FastAPI backend
│       └── tflite_classifier_service.dart # Opsional on-device TFLite
├── domain/ / providers/     # State management (ScanNotifier, HistoryNotifier)
└── presentation/
    ├── screens/            # Splash, Home, Scan, Result, History, Stats, Settings
    └── widgets/            # QualityBadge, ConfidenceBar, MetricCard, FramingOverlay
```

### Abstraksi Inferensi (Kunci Fleksibilitas)
```dart
abstract class IClassifierService {
  Future<PredictionResult> predict(File imageFile);
}
```
*Dengan abstraksi ini, beralih dari Mock ➡️ REST API ➡️ TFLite hanya memerlukan penggantian 1 baris dependency injection.*

---

## 4. Standar UI/UX & Desain Visual

Sesuai Bab 7 di Dokumen Kebutuhan:
* **Palette Warna Utama:**
  * Primary Green: `#43A047` (Segar & Modern)
  * Background Light: `#F5F7F5`
  * Surface / Card: `#FFFFFF`
* **Badge Status Kualitas Buah:**
  * 🟢 **Bagus:** `#2E7D32` (Badge hijau + icon ceklis)
  * 🟡 **Cukup:** `#F9A825` (Badge oranye/kuning + icon peringatan)
  * 🔴 **Busuk:** `#C62828` (Badge merah + icon silang)
* **Wajib Menyediakan 4 State pada Setiap Layar:**
  1. *Loading State:* Indikator animasi halus (misal: "Sedang menganalisis buah...").
  2. *Success State:* Data tampil rapi dengan hierarki tipografi yang jelas.
  3. *Empty State:* Ilustrasi/ikon ramah + teks call-to-action (misal: "Belum ada riwayat sortir").
  4. *Error State:* Pesan manusiawi + tombol aksi ("Coba Lagi" / "Buka Pengaturan").

---

## 5. Kontrak Data & Kesepakatan API

### Kontrak Prediksi (`POST /predict`)
* **Request:** `multipart/form-data` dengan key `image` (JPG/PNG, otomatis dikompres maks 1024px / 2MB).
* **Format Response Sukses (200):**
```json
{
  "success": true,
  "fruit": "apel",
  "quality": "bagus",
  "confidence": 0.93,
  "probabilities": {
    "bagus": 0.93,
    "cukup": 0.05,
    "busuk": 0.02
  },
  "inference_time_ms": 142
}
```
* **Kategori Kualitas yang Didukung:** `bagus`, `cukup`, `busuk`.
* **Kategori Buah:** `apel`, `jeruk`, `pisang`, `mangga`, `tomat` (dapat dikembangkan).

---

## 6. Template & Resep Prompt Vibe Coding

Saat meminta AI melakukan pengerjaan, gunakan pola prompt yang terarah seperti contoh berikut:

### 🚀 Resep 1: Membuat Layar Baru (UI Screen)
```text
Buatkan halaman [NamaScreen] sesuai panduan desain di AGENTS.md.
Pastikan menyertakan:
- Loading, Empty, dan Error state
- Penggunaan warna tema dari core/constants/colors.dart
- Reusable widget terpisah untuk komponen berulang
- Responsif untuk berbagai resolusi layar
```

### ⚡ Resep 2: Menghubungkan Fitur dengan Mock Service
```text
Implementasikan [Fitur] dengan menghubungkannya ke MockClassifierService terlebih dahulu.
Sertakan delay buatan (800ms) untuk mensimulasikan proses inferensi dan pastikan
data dummy memiliki variasi kualitas (bagus, cukup, busuk).
```

### 🛠️ Resep 3: Operasi Database SQLite
```text
Buatkan DatabaseHelper untuk tabel scan_history sesuai Bab 8 AGENTS.md.
Sertakan method CRUD: insertScan, getAllHistory(filter, sort), deleteById, clearAll,
serta method agregasi untuk menghitung total buah bagus/cukup/busuk untuk halaman statistik.
```

### 🔍 Resep 4: Debugging Error
```text
Terjadi error [salin pesan error] pada saat [langkah kejadian].
Gunakan skill debugging-and-error-recovery untuk menganalisis akar masalah,
periksa izin/lifecycle/null-safety, dan berikan solusi yang tidak merusak komponen lain.
```

---

## 7. Aturan Main & Batasan Kualitas (Quality Constraints)

- ❌ **Dilarang keras:** Menulis logika bisnis langsung di dalam widget `build()` (pisahkan ke controller/notifier/service).
- ❌ **Dilarang keras:** Mengirim gambar mentah berukuran besar (> 5MB) tanpa kompresi client-side.
- ❌ **Dilarang keras:** Mengabaikan penanganan izin kamera yang ditolak oleh user.
- ✅ **Wajib:** Memastikan aplikasi dapat dijalankan secara offline sepenuhnya menggunakan mode Mock Service untuk keperluan testing dan demo darurat.
- ✅ **Wajib:** Menggunakan pesan error berbahasa Indonesia yang ramah pengguna.
- ✅ **Wajib:** Selalu membersihkan controller (`dispose()`) pada kamera, text controller, dan animation controller untuk mencegah memory leak.
