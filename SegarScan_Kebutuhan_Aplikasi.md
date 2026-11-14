# SegarScan: Dokumen Kebutuhan Aplikasi Mobile

> **Tagline:** *Sortir buah jadi cepat, cukup sekali jepret.*

| Item | Keterangan |
|---|---|
| Nama Aplikasi | **SegarScan** |
| Mata Kuliah | Computer Vision |
| Jenis Proyek | Tugas Besar (Tubes) |
| Anggota Tim | 2 orang (Mobile App Developer, Computer Vision Engineer) |
| Studi Kasus | Sistem Sortir Kualitas Buah |
| Platform | Android (opsional iOS jika memakai Flutter/React Native) |
| Status Dokumen | Draft v1.0 |

> Alternatif nama jika ingin diganti: **SortiBuah**, **BuahCek**, **Segarin**, **FreshSort**.

---

## 1. Pendahuluan

### 1.1 Latar Belakang
Penyortiran kualitas buah umumnya dilakukan secara manual dengan mata manusia. Cara ini lambat, subjektif, dan tidak konsisten antar petugas. Dengan computer vision, kualitas buah dapat dinilai otomatis dari citra, sehingga proses sortir menjadi lebih cepat, objektif, dan dapat diakses siapa saja lewat smartphone.

### 1.2 Tujuan
1. Membangun aplikasi mobile yang dapat mengambil/memilih citra buah dan menampilkan hasil klasifikasi jenis serta kualitas buah.
2. Mengintegrasikan model computer vision ke dalam aplikasi mobile.
3. Menyediakan riwayat dan statistik hasil sortir sebagai pendukung keputusan.

### 1.3 Ruang Lingkup

**Termasuk (versi awal):**
- Klasifikasi kualitas **buah** dari satu gambar.
- Input dari kamera dan galeri.
- Riwayat dan statistik hasil scan.

**Tidak termasuk (opsi pengembangan lanjutan):**
- Sortir **sayuran**.
- Deteksi banyak buah sekaligus dalam satu frame (object detection).
- Deteksi real-time lewat kamera live.
- Akun pengguna dan sinkronisasi cloud.
- Integrasi dengan perangkat sortir fisik (konveyor, aktuator).

### 1.4 Pembagian Tugas Tim

| Peran | Tanggung Jawab |
|---|---|
| Developer Mobile (kamu) | UI/UX, kamera, integrasi API/model, penyimpanan lokal, riwayat, statistik, pengujian aplikasi |
| Engineer CV (teman) | Dataset, pelatihan model, evaluasi model, penyediaan endpoint API atau file model (.tflite) |

---

## 2. Pengguna dan Skenario

### 2.1 Target Pengguna
- Petani dan pedagang buah skala kecil.
- Penjual di pasar atau toko buah.
- Konsumen yang ingin mengecek kualitas buah.
- Dosen/penguji (untuk keperluan demo).

### 2.2 Skenario Penggunaan Utama
1. Pengguna membuka aplikasi dan menekan **Mulai Scan**.
2. Pengguna memotret buah atau memilih foto dari galeri.
3. Aplikasi mengirim gambar ke model CV.
4. Aplikasi menampilkan jenis buah, kualitas, dan confidence.
5. Pengguna menyimpan hasil ke riwayat atau scan ulang.
6. Pengguna melihat rekap statistik di menu Statistik.

---

## 3. Arsitektur Sistem

### 3.1 Pilihan Arsitektur Inferensi (disepakati bersama teman)

| Aspek | Opsi A: Server/API | Opsi B: On-device (TFLite) |
|---|---|---|
| Cara kerja | App kirim gambar ke server, server balas hasil | Model jalan langsung di HP |
| Kelebihan | Cepat dikerjakan, model bebas besar, kerja tim terpisah rapi | Offline, cepat, tidak butuh server saat demo |
| Kekurangan | Butuh internet dan server hidup saat demo | Model harus dikonversi dan dioptimasi |
| Rekomendasi | Cocok jika waktu terbatas | Cocok jika dosen mensyaratkan on-device |

**Rekomendasi:** mulai dari Opsi A (API), siapkan lapisan abstraksi agar nanti bisa diganti ke Opsi B tanpa mengubah UI.

### 3.2 Diagram Alur (Opsi A)

```
[Pengguna] -> [Kamera/Galeri] -> [Preprocessing ringan di app]
     -> [HTTP POST ke API] -> [Model CV di server]
     -> [JSON hasil] -> [Halaman Hasil] -> [Simpan ke DB lokal]
```

### 3.3 Komponen Aplikasi
- **Presentation layer:** halaman dan widget UI.
- **Domain/service layer:** logika scan, klasifikasi, statistik.
- **Data layer:** klien API/TFLite, database lokal, penyimpanan gambar.

---

## 4. Kontrak Antarmuka dengan Modul CV

Bagian ini **wajib disepakati dengan teman** agar pekerjaan tidak saling menunggu.

### 4.1 Endpoint (jika memakai API)

**`POST /predict`**
- Content-Type: `multipart/form-data`
- Field: `image` (file JPG/PNG)

**Response sukses (200):**
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

**Response gagal (4xx/5xx):**
```json
{
  "success": false,
  "error_code": "INVALID_IMAGE",
  "message": "Gambar tidak dapat diproses"
}
```

### 4.2 Kesepakatan Label

| Atribut | Nilai yang Diizinkan |
|---|---|
| `fruit` | Disepakati dengan tim CV, contoh: apel, jeruk, pisang, mangga, tomat |
| `quality` | `bagus`, `cukup`, `busuk` |
| `confidence` | 0.0 sampai 1.0 |

### 4.3 Kesepakatan Input Gambar
- Format: JPG atau PNG.
- Ukuran maksimal yang dikirim: 1024 px sisi terpanjang (app melakukan resize/kompresi).
- Ukuran file maksimal: 2 MB.

### 4.4 Jika Memakai On-Device
- Format model: `.tflite` (atau ONNX).
- File `labels.txt` berisi daftar kelas berurutan.
- Spesifikasi input: ukuran (misal 224x224), normalisasi, urutan channel (RGB), tipe data. **Harus dari tim CV.**

---

## 5. Kebutuhan Fungsional

Prioritas: **P1** = wajib, **P2** = penting, **P3** = tambahan.

### 5.1 Modul Scan

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-01 | Aplikasi dapat menampilkan preview kamera | P1 |
| FR-02 | Pengguna dapat mengambil foto dari kamera | P1 |
| FR-03 | Pengguna dapat memilih foto dari galeri | P1 |
| FR-04 | Aplikasi meminta izin kamera dan penyimpanan, serta menangani penolakan izin | P1 |
| FR-05 | Aplikasi menyediakan tombol flash on/off | P2 |
| FR-06 | Aplikasi menyediakan tombol ganti kamera depan/belakang | P3 |
| FR-07 | Aplikasi menampilkan panduan framing (kotak bantu di tengah layar) | P2 |
| FR-08 | Pengguna dapat memotong (crop) gambar sebelum dianalisis | P3 |
| FR-09 | Aplikasi menampilkan indikator loading saat menganalisis | P1 |
| FR-10 | Aplikasi mengompres dan me-resize gambar sebelum dikirim/diproses | P1 |

### 5.2 Modul Hasil Klasifikasi

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-11 | Menampilkan foto yang dianalisis | P1 |
| FR-12 | Menampilkan jenis buah | P1 |
| FR-13 | Menampilkan label kualitas dengan kode warna (hijau/kuning/merah) | P1 |
| FR-14 | Menampilkan nilai confidence dalam persen dan progress bar | P1 |
| FR-15 | Menampilkan probabilitas tiap kelas kualitas | P2 |
| FR-16 | Menampilkan rekomendasi singkat (misal "Layak jual", "Segera dijual", "Pisahkan") | P2 |
| FR-17 | Tombol **Simpan** ke riwayat | P1 |
| FR-18 | Tombol **Scan Lagi** | P1 |
| FR-19 | Peringatan jika confidence di bawah ambang batas (misal < 60%) agar pengguna memotret ulang | P2 |
| FR-20 | Tombol bagikan hasil sebagai gambar/teks | P3 |

### 5.3 Modul Riwayat

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-21 | Menampilkan daftar hasil scan (thumbnail, jenis, kualitas, tanggal, confidence) | P1 |
| FR-22 | Melihat detail satu riwayat | P1 |
| FR-23 | Menghapus satu riwayat (swipe atau tombol) | P1 |
| FR-24 | Menghapus seluruh riwayat dengan dialog konfirmasi | P2 |
| FR-25 | Filter berdasarkan kualitas dan jenis buah | P2 |
| FR-26 | Pencarian berdasarkan nama buah | P3 |
| FR-27 | Pengurutan berdasarkan tanggal | P2 |
| FR-28 | Ekspor riwayat ke CSV | P3 |

### 5.4 Modul Statistik

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-29 | Menampilkan total scan | P2 |
| FR-30 | Menampilkan grafik perbandingan Bagus / Cukup / Busuk (pie atau bar) | P2 |
| FR-31 | Menampilkan jumlah scan per jenis buah | P2 |
| FR-32 | Menampilkan persentase buah layak jual | P3 |
| FR-33 | Filter statistik berdasarkan rentang waktu (hari ini, 7 hari, semua) | P3 |

### 5.5 Modul Beranda

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-34 | Sapaan dan deskripsi singkat aplikasi | P2 |
| FR-35 | Tombol pintas **Mulai Scan** | P2 |
| FR-36 | Ringkasan cepat (total scan, jumlah bagus, jumlah busuk) | P2 |
| FR-37 | Daftar 3 sampai 5 scan terakhir | P2 |

### 5.6 Modul Pengaturan dan Tentang

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-38 | Pengaturan URL/endpoint API | P2 |
| FR-39 | Pilihan mode inferensi (API / on-device) jika keduanya tersedia | P3 |
| FR-40 | Pengaturan ambang batas confidence | P3 |
| FR-41 | Tema terang/gelap | P3 |
| FR-42 | Tombol hapus seluruh data | P2 |
| FR-43 | Halaman Tentang: info tim, versi, penjelasan model, daftar buah yang didukung | P2 |

### 5.7 Onboarding

| ID | Kebutuhan | Prioritas |
|---|---|---|
| FR-44 | Splash screen dengan logo SegarScan | P2 |
| FR-45 | Onboarding 2 sampai 3 halaman pada peluncuran pertama (cara pakai dan tips foto) | P3 |

---

## 6. Kebutuhan Non-Fungsional

| ID | Kategori | Kebutuhan |
|---|---|---|
| NFR-01 | Kinerja | Waktu dari tombol ambil foto sampai hasil muncul maksimal 5 detik (API, jaringan normal) atau 2 detik (on-device) |
| NFR-02 | Kinerja | Aplikasi tidak freeze saat proses analisis (proses berjalan asinkron) |
| NFR-03 | Usability | Alur scan hingga hasil maksimal 3 ketukan |
| NFR-04 | Usability | Teks dan tombol terbaca jelas, kontras warna memadai |
| NFR-05 | Keandalan | Aplikasi menangani error jaringan, timeout, dan respons tidak valid tanpa crash |
| NFR-06 | Kompatibilitas | Android 8.0 (API 26) ke atas |
| NFR-07 | Penyimpanan | Data riwayat tersimpan lokal dan tetap ada setelah aplikasi ditutup |
| NFR-08 | Privasi | Gambar hanya dikirim ke server tim sendiri, tidak ke pihak ketiga |
| NFR-09 | Keamanan | Komunikasi API memakai HTTPS jika server dipublikasikan |
| NFR-10 | Maintainability | Kode terstruktur berlapis agar sumber inferensi mudah diganti |
| NFR-11 | Lokalisasi | Antarmuka berbahasa Indonesia |
| NFR-12 | Responsif | Tampilan menyesuaikan berbagai ukuran layar HP |

---

## 7. Desain Antarmuka

### 7.1 Navigasi
Bottom navigation dengan 4 tab:

| Tab | Isi |
|---|---|
| Beranda | Ringkasan dan akses cepat |
| Scan | Kamera dan galeri |
| Riwayat | Daftar hasil |
| Statistik | Grafik rekap |

Pengaturan dan Tentang diakses dari ikon di pojok Beranda.
Halaman Hasil muncul setelah proses scan (bukan tab).

### 7.2 Daftar Halaman

| No | Halaman | Deskripsi |
|---|---|---|
| 1 | Splash | Logo dan nama aplikasi |
| 2 | Onboarding | Panduan singkat pemakaian |
| 3 | Beranda | Ringkasan dan tombol Mulai Scan |
| 4 | Scan | Preview kamera, tombol shutter, galeri, flash |
| 5 | Loading Analisis | Animasi "Menganalisis..." |
| 6 | Hasil | Foto, jenis, kualitas, confidence, aksi |
| 7 | Riwayat | List dan filter |
| 8 | Detail Riwayat | Info lengkap satu scan |
| 9 | Statistik | Grafik dan angka rekap |
| 10 | Pengaturan | Endpoint, tema, hapus data |
| 11 | Tentang | Info tim dan model |

### 7.3 Panduan Visual
- **Tema:** segar dan bersih, dominan hijau.
- **Kode warna kualitas:**

| Kualitas | Warna | Contoh Hex |
|---|---|---|
| Bagus | Hijau | `#2E7D32` |
| Cukup | Kuning/Oranye | `#F9A825` |
| Busuk | Merah | `#C62828` |

- **Warna utama:** hijau `#43A047`, latar putih/abu muda `#F5F7F5`.
- **Font:** sans-serif bersih (misal Poppins atau Inter).
- **Ikon:** satu set ikon konsisten (Material Icons / Lucide).

### 7.4 Kondisi Khusus yang Harus Ada Tampilannya (Empty/Error State)
- Riwayat kosong: ilustrasi dan teks "Belum ada hasil scan".
- Statistik kosong: ajakan untuk mulai scan.
- Izin kamera ditolak: penjelasan dan tombol menuju pengaturan.
- Gagal terhubung ke server: pesan dan tombol **Coba Lagi**.
- Buah tidak terdeteksi / confidence rendah: saran memotret ulang.

---

## 8. Model Data Lokal

### 8.1 Tabel `scan_history`

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | INTEGER (PK, auto) | ID unik |
| image_path | TEXT | Lokasi file gambar di penyimpanan |
| fruit_name | TEXT | Jenis buah |
| quality | TEXT | bagus / cukup / busuk |
| confidence | REAL | 0.0 sampai 1.0 |
| prob_good | REAL | Probabilitas kelas bagus |
| prob_fair | REAL | Probabilitas kelas cukup |
| prob_bad | REAL | Probabilitas kelas busuk |
| inference_ms | INTEGER | Waktu inferensi |
| source | TEXT | api / ondevice |
| created_at | TEXT (ISO 8601) | Waktu scan |

### 8.2 Penyimpanan Pengaturan (key-value)

| Key | Contoh Nilai |
|---|---|
| api_base_url | `http://192.168.1.10:8000` |
| inference_mode | `api` |
| confidence_threshold | `0.6` |
| theme_mode | `light` |
| onboarding_done | `true` |

---

## 9. Alur Kerja Detail

### 9.1 Alur Scan
1. Pengguna membuka tab Scan, aplikasi memeriksa izin kamera.
2. Jika izin belum ada, tampilkan permintaan izin. Jika ditolak, tampilkan penjelasan.
3. Pengguna mengambil foto atau memilih dari galeri.
4. Aplikasi melakukan resize dan kompresi.
5. Tampilkan loading, kirim gambar ke API (atau jalankan model lokal).
6. Terima respons, validasi format JSON.
7. Jika sukses, buka Halaman Hasil. Jika gagal, tampilkan pesan error dengan opsi coba lagi.
8. Pengguna menekan Simpan, data masuk ke `scan_history`.

### 9.2 Alur Penanganan Error

| Kondisi | Respons Aplikasi |
|---|---|
| Tidak ada internet / server mati | Pesan "Tidak dapat terhubung ke server" + tombol Coba Lagi |
| Timeout (> 15 detik) | Pesan timeout + opsi coba lagi |
| Respons JSON tidak valid | Pesan "Terjadi kesalahan saat memproses hasil" |
| Confidence < ambang batas | Hasil tetap tampil dengan peringatan hasil kurang meyakinkan |
| Gambar terlalu gelap/buram | Saran memotret ulang di tempat lebih terang |

---

## 10. Rekomendasi Teknologi

| Komponen | Flutter (Rekomendasi) | React Native | Kotlin Native |
|---|---|---|---|
| Kamera | `camera` | `react-native-vision-camera` | CameraX |
| Galeri | `image_picker` | `react-native-image-picker` | Photo Picker |
| HTTP | `dio` / `http` | `axios` | Retrofit |
| DB Lokal | `sqflite` / `drift` / `isar` | `WatermelonDB` / SQLite | Room |
| State Mgmt | `provider` / `riverpod` / `bloc` | Redux / Zustand | ViewModel + Flow |
| Grafik | `fl_chart` | `victory-native` | MPAndroidChart |
| On-device | `tflite_flutter` | `react-native-fast-tflite` | TensorFlow Lite Android |
| Izin | `permission_handler` | `react-native-permissions` | ActivityResult API |

**Sisi server (tim CV):** Python + FastAPI/Flask, model TensorFlow/PyTorch, deploy lokal (jaringan WiFi yang sama) atau tunneling (ngrok) untuk demo.

---

## 11. Struktur Folder yang Disarankan (Flutter)

```
segarscan/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── constants/        # warna, string, endpoint
│   │   ├── theme/
│   │   └── utils/            # helper format tanggal, kompres gambar
│   ├── data/
│   │   ├── models/           # ScanResult, PredictionResponse
│   │   ├── services/         # api_service.dart, tflite_service.dart
│   │   ├── repositories/     # classifier_repository.dart
│   │   └── local/            # database_helper.dart
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── splash/
│   │   │   ├── onboarding/
│   │   │   ├── home/
│   │   │   ├── scan/
│   │   │   ├── result/
│   │   │   ├── history/
│   │   │   ├── statistics/
│   │   │   ├── settings/
│   │   │   └── about/
│   │   └── widgets/          # quality_badge, confidence_bar, scan_card
│   └── providers/            # state management
├── assets/
│   ├── images/
│   └── models/               # (opsional) model.tflite, labels.txt
└── pubspec.yaml
```

---

## 12. Rencana Pengujian

| Jenis | Skenario | Hasil yang Diharapkan |
|---|---|---|
| Fungsional | Ambil foto lalu analisis | Hasil muncul dengan data lengkap |
| Fungsional | Pilih dari galeri lalu analisis | Hasil muncul dengan data lengkap |
| Fungsional | Simpan hasil, buka Riwayat | Data muncul di daftar teratas |
| Fungsional | Hapus riwayat | Data hilang dari daftar dan statistik ikut berubah |
| Izin | Tolak izin kamera | Muncul penjelasan, tidak crash |
| Jaringan | Matikan server/internet saat scan | Muncul pesan error dan opsi coba lagi |
| Edge case | Foto bukan buah | Confidence rendah atau peringatan |
| Edge case | Foto gelap/buram | Peringatan atau hasil dengan confidence rendah |
| Kinerja | Ukur waktu analisis 10 kali | Rata-rata sesuai NFR-01 |
| Kompatibilitas | Uji di minimal 2 perangkat/emulator berbeda | Tampilan dan fungsi normal |
| Integrasi | Uji end-to-end bersama modul CV | Format request/response sesuai kontrak |

---

## 13. Rencana Pengerjaan (Roadmap)

| Fase | Pekerjaan | Output |
|---|---|---|
| 1. Persiapan | Sepakati arsitektur, kontrak API, daftar label | Dokumen kontrak disetujui berdua |
| 2. Desain | Wireframe/mockup (Figma) semua halaman utama | File desain |
| 3. Fondasi | Setup proyek, tema, navigasi, struktur folder | Kerangka app berjalan |
| 4. Inti | Kamera, galeri, halaman hasil, integrasi API (pakai mock dulu) | Alur scan berjalan dengan data dummy |
| 5. Integrasi | Sambung ke endpoint/model asli dari teman | Scan nyata berjalan |
| 6. Pendukung | Riwayat, Beranda, Statistik | Fitur lengkap |
| 7. Penyempurnaan | Error handling, empty state, polesan UI, Pengaturan/Tentang | App stabil |
| 8. Pengujian | Uji fungsional dan integrasi, perbaikan bug | Laporan pengujian |
| 9. Finalisasi | Build APK, siapkan demo, dokumentasi | APK dan materi presentasi |

**Tips:** pada Fase 4, buat **mock service** yang mengembalikan JSON contoh agar kamu tidak menunggu model dari temanmu selesai.

---

## 14. Daftar Prioritas Fitur (MVP)

**Wajib (MVP):**
- Scan via kamera dan galeri
- Halaman hasil (jenis, kualitas, confidence)
- Simpan dan lihat riwayat
- Error handling dasar

**Penting:**
- Beranda
- Statistik
- Filter riwayat
- Pengaturan endpoint API

**Nilai tambah:**
- Tema gelap
- Ekspor CSV
- Onboarding
- Bagikan hasil
- Mode on-device

---

## 15. Opsi Pengembangan Lanjutan

1. **Ekspansi ke sayuran** (tomat, cabai, wortel, dll.) dengan menambah kelas dan dataset.
2. **Object detection** untuk menyortir banyak buah dalam satu foto, lengkap dengan bounding box.
3. **Deteksi real-time** lewat kamera live.
4. **Estimasi kematangan** (mentah, matang, terlalu matang) dan estimasi sisa umur simpan.
5. **Grading berstandar** (misal Grade A/B/C) sesuai standar pasar.
6. **Akun dan cloud sync** untuk riwayat lintas perangkat.
7. **Integrasi perangkat keras** (konveyor + kamera + aktuator pemilah) untuk sortir otomatis skala nyata.
8. **Laporan PDF** hasil sortir per periode.

---

## 16. Risiko dan Mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Model teman belum siap saat app jadi | Integrasi tertunda | Pakai mock service sejak awal |
| Format respons berubah di tengah jalan | App error | Kunci kontrak API di awal dan buat parser yang toleran |
| Server tidak bisa diakses saat demo | Demo gagal | Siapkan mode on-device atau video/demo cadangan, jalankan server di laptop pada WiFi yang sama |
| Akurasi model rendah pada foto dunia nyata | Hasil kurang meyakinkan | Beri panduan foto (pencahayaan, latar polos), tampilkan peringatan confidence rendah |
| Perbedaan hasil di emulator dan HP asli | Bug saat demo | Uji di HP fisik sejak dini |
| Waktu pengerjaan mepet | Fitur tidak selesai | Kerjakan sesuai prioritas MVP |

---

## 17. Kriteria Keberhasilan

- [ ] Aplikasi dapat memotret/memilih gambar buah dan menampilkan hasil klasifikasi yang benar dari model asli.
- [ ] Hasil menampilkan jenis, kualitas, dan confidence dengan jelas.
- [ ] Riwayat tersimpan dan tetap ada setelah aplikasi ditutup.
- [ ] Aplikasi tidak crash pada skenario error yang diuji.
- [ ] Integrasi dengan modul CV berjalan sesuai kontrak.
- [ ] Demo berjalan lancar pada perangkat nyata.

---

## 18. Daftar Hal yang Perlu Dikonfirmasi

**Ke dosen:**
- Apakah model wajib berjalan on-device atau boleh lewat server?
- Apakah ada batasan framework/bahasa pemrograman?
- Format pengumpulan (APK, source code, laporan, video demo)?

**Ke teman (tim CV):**
- Daftar jenis buah dan kelas kualitas final.
- Arsitektur/model yang dipakai dan akurasi saat ini.
- Format endpoint atau spesifikasi input model `.tflite`.
- Estimasi kapan endpoint/model pertama bisa dicoba.
- Cara menjalankan server saat demo.

---

*Dokumen ini bersifat draft dan dapat diperbarui seiring kesepakatan tim dan arahan dosen.*
