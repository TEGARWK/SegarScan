# 🤝 SegarScan — API Contract & Backend Integration Guide

> **Tujuan Dokumen:** Menjadi acuan tunggal dan kontrak resmi integrasi antara **Mobile App Developer** dan **Computer Vision Engineer**.

---

## 1. Spesifikasi Endpoint

### **POST /predict**
Menerima satu citra buah, melakukan inferensi klasifikasi citra, dan mengembalikan hasil deteksi jenis buah beserta kualitas mutunya.

- **URL:** `http://<IP-HOST>:8000/predict`
- **Method:** `POST`
- **Content-Type:** `multipart/form-data`
- **Timeout Maksimal Rekomendasi:** 10.000 ms (10 detik)

---

## 2. Parameter Request

| Field | Tipe | Wajib | Keterangan |
|---|---|---|---|
| `image` | File Binary (`image/jpeg` atau `image/png`) | Ya | File gambar yang dikompres (maks 1024px sisi terpanjang, ukuran < 2MB). |

---

## 3. Spesifikasi Response

### ✅ Response Sukses (`200 OK`)
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

#### Kamus Data Field Response:
* `success` *(boolean)*: Status pemrosesan citra.
* `fruit` *(string)*: Label jenis buah (lowercase: `apel`, `jeruk`, `pisang`, `mangga`, `tomat`).
* `quality` *(string)*: Label mutu buah (hanya salah satu dari: `bagus`, `cukup`, `busuk`).
* `confidence` *(float)*: Nilai kepercayaan kelas terpilih (rentang `0.00` s.d. `1.00`).
* `probabilities` *(object)*: Distribusi probabilitas ketiga kelas mutu (total penjumlahan = 1.0).
* `inference_time_ms` *(integer)*: Durasi komputasi model di server dalam milidetik.

---

### ❌ Response Gagal (`400 Bad Request` / `422 Unprocessable Entity` / `500 Internal Error`)
```json
{
  "success": false,
  "error_code": "INVALID_IMAGE",
  "message": "Gambar tidak dapat dibaca atau rusak"
}
```

#### Daftar Kode Error Standar:
| Error Code | HTTP Status | Penjelasan |
|---|---|---|
| `NO_IMAGE_PROVIDED` | 400 | Field `image` kosong atau tidak disertakan dalam multipart. |
| `INVALID_IMAGE_FORMAT` | 415 | Format file bukan JPEG atau PNG. |
| `IMAGE_CORRUPTED` | 422 | Citra tidak dapat di-decode oleh OpenCV/PIL. |
| `INFERENCE_FAILED` | 500 | Terjadi kesalahan saat model melakukan inferensi. |

---

## 4. Perintah Pengujian dengan cURL

Untuk menguji apakah endpoint backend tim CV sudah berjalan dengan benar:

```bash
curl -X POST "http://localhost:8000/predict" \
  -H "accept: application/json" \
  -H "Content-Type: multipart/form-data" \
  -F "image=@sample_apel.jpg"
```

---

## 5. Starter Mock Server FastAPI (Untuk Rekan Tim CV / Pengujian Mandiri)

Rekan tim CV dapat menggunakan template FastAPI minimal berikut ini sebagai fondasi endpoint sebelum model sesungguhnya dipasang:

```python
# main.py
import time
import random
from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="SegarScan CV Inference API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

FRUITS = ["apel", "jeruk", "pisang", "mangga"]
QUALITIES = ["bagus", "cukup", "busuk"]

@app.get("/")
def health_check():
    return {"status": "ok", "app": "SegarScan CV API"}

@app.post("/predict")
async def predict(image: UploadFile = File(...)):
    start_time = time.time()
    
    if not image.content_type.startswith("image/"):
        raise HTTPException(
            status_code=415,
            detail={"success": False, "error_code": "INVALID_IMAGE_FORMAT", "message": "File harus berupa citra JPG/PNG"}
        )
    
    # Baca file citra
    contents = await image.read()
    if len(contents) == 0:
        raise HTTPException(
            status_code=400,
            detail={"success": False, "error_code": "EMPTY_IMAGE", "message": "File citra kosong"}
        )
    
    # TODO: Rekan CV menghubungkan model PyTorch/TensorFlow di sini
    # Simulasi inferensi acak untuk dummy test:
    time.sleep(0.15) # Simulasi latensi 150ms
    chosen_fruit = random.choice(FRUITS)
    chosen_quality = random.choice(QUALITIES)
    conf = round(random.uniform(0.75, 0.98), 2)
    
    rem = round(1.0 - conf, 2)
    p2 = round(rem * 0.7, 2)
    p3 = round(rem - p2, 2)
    
    elapsed_ms = int((time.time() - start_time) * 1000)
    
    return {
        "success": True,
        "fruit": chosen_fruit,
        "quality": chosen_quality,
        "confidence": conf,
        "probabilities": {
            "bagus": conf if chosen_quality == "bagus" else p2,
            "cukup": conf if chosen_quality == "cukup" else (p3 if chosen_quality == "bagus" else p2),
            "busuk": conf if chosen_quality == "busuk" else p3,
        },
        "inference_time_ms": elapsed_ms
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
```
