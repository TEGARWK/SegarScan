# 🛡️ SegarScan — Engineering Constraints & Quality Bar

> **Dokumen Kontrak Kualitas:** Sesuai panduan `constraint-driven-development`, dokumen ini memuat batasan teknis (thresholds) dan standar kualitas mutlak yang tidak boleh diturunkan selama proses pengembangan.

---

## 1. Ambang Batas Kinerja (Performance Thresholds)

| Metrik | Batas Maksimal / Target | Aturan Penegakan |
|---|---|---|
| **Waktu inferensi (NFR-01)** | `< 5.0 detik` (via API di jaringan normal), `< 2.0 detik` (on-device) | Gunakan stopwatch/log `inference_time_ms`. Tampilkan animasi loading jika proses berlangsung > 300ms. |
| **Ukuran Gambar Upload** | Panjang sisi maks: `1024 px`, Ukuran file: `< 2.0 MB` | Wajib kompresi citra di sisi mobile *sebelum* dikirim ke API backend atau model TFLite. |
| **Durasi Startup / Splash** | `< 2.0 detik` | Hindari blocking IO pada fase `main()` atau inisialisasi awal. |
| **Frame Rate UI** | Konsisten `60 FPS` | Dilarang menjalankan komputasi berat, hashing, atau parsing data besar di UI thread utama (gunakan `Isolate`/`compute`). |

---

## 2. Batasan Interaksi & UX (Usability Constraints)

- **Maksimal 3 Ketukan (NFR-03):** Alur dari membuka tab Scan ➡️ Mengambil/memilih foto ➡️ Melihat hasil klasifikasi tidak boleh melebihi 3 ketukan layar.
- **Mandatori 4 State pada Setiap Layar:**
  1. *Loading State:* Spinner / shimmer / progress bar dengan label informatif.
  2. *Success State:* Tampilan rapi berhierarki dengan typography jelas.
  3. *Empty State:* Ikon/ilustrasi ramah + CTA (Call to action) yang jelas.
  4. *Error State:* Bahasa ramah pengguna berbahasa Indonesia + tombol *Coba Lagi*.
- **Aksesibilitas Kontras Warna (WCAG AA):** Teks pada badge status (Bagus, Cukup, Busuk) harus memiliki kontras tinggi terhadap latar belakangnya.

---

## 3. Batasan Kualitas Kode & Arsitektur (Engineering Rules)

- ❌ **Zero Linting Suppression:** Dilarang menggunakan `// ignore: ...` atau `// ignore_for_file: ...` untuk menyembunyikan warning/error lint Dart. Perbaiki masalah pada akarnya.
- ❌ **No Business Logic in Widget `build()`:** Logika kalkulasi, navigasi otomatis, panggilan HTTP, atau operasi database dilarang ditulis di dalam method `build()`.
- ❌ **No Raw `print()` Statements:** Gunakan logger terstruktur (`debugPrint` atau class logger khusus) yang dapat dimatikan di mode release.
- ❌ **No Memory Leaks:** Semua instance `CameraController`, `TextEditingController`, `AnimationController`, dan stream subscription wajib di-`dispose()` saat widget dilepas.
- ✅ **Offline Resilience:** Seluruh alur aplikasi (Scan, Hasil, Riwayat, Statistik) harus dapat didemokan secara penuh dalam kondisi **offline tanpa internet** menggunakan `MockClassifierService`.
- ✅ **Lokalisasi Bahasa Indonesia:** Semua string UI, label tombol, dialog konfirmasi, dan pesan error menggunakan Bahasa Indonesia yang komunikatif dan ramah pengguna.
