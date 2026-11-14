# 🥑 SegarScan — Mobile Fruit Quality Sorter (Computer Vision)

> **Sortir buah jadi cepat, cukup sekali jepret.**  
> Aplikasi mobile berbasis Computer Vision untuk mendeteksi jenis dan mutu kualitas buah secara otomatis, objektif, dan portabel.

---

## 📚 Pusat Dokumentasi Proyek

Untuk mendukung alur pengerjaan yang cepat, terarah, dan berkualitas tinggi (*Vibe Coding with Engineering Rigor*), proyek ini dilengkapi dengan panduan lengkap:

| Dokumen | Deskripsi & Kegunaan |
|---|---|
| [AGENTS.md](file:///d:/project/SegarScan/AGENTS.md) | **Vibe Coding Playbook & Agent Guide** — Panduan filosofi, pemetaan skill AI, arsitektur, dan resep prompt siap pakai. |
| [SegarScan_Kebutuhan_Aplikasi.md](file:///d:/project/SegarScan/SegarScan_Kebutuhan_Aplikasi.md) | **Dokumen Spesifikasi Kebutuhan (SRS)** — Single source of truth untuk fitur fungsional, non-fungsional, skema DB, dan alur aplikasi. |
| [ROADMAP.md](file:///d:/project/SegarScan/ROADMAP.md) | **Progress Tracker & Task Checklist** — Checklist pengerjaan bertahap dari Fase 1 hingga Fase 7 (MVP ke Polish). |
| [API_CONTRACT.md](file:///d:/project/SegarScan/API_CONTRACT.md) | **Kontrak API & Panduan Tim CV** — Spesifikasi `POST /predict`, format multipart, respon JSON, dan starter server mock FastAPI. |
| [CONSTRAINTS.md](file:///d:/project/SegarScan/CONSTRAINTS.md) | **Quality Bar & NFR Thresholds** — Batasan teknis latensi (<5s), kompresi gambar, zero lint errors, dan offline readiness. |
| [UI_DESIGN_SYSTEM.md](file:///d:/project/SegarScan/UI_DESIGN_SYSTEM.md) | **Design System & Visual Tokens** — Token warna tema, status badge buah, tipografi, dan spesifikasi reusable widgets. |

---

## 🛠️ Tech Stack Rekomendasi
* **Framework:** Flutter (Android/iOS)
* **Kamera & Galeri:** `camera`, `image_picker`
* **Local Database:** `sqflite` (SQLite)
* **Visualisasi Statistik:** `fl_chart`
* **HTTP Client:** `dio`
* **CV Inference:** REST API FastAPI (Server) / TensorFlow Lite (On-device fallback)
