# POS Voice Assistant (Tahap 3 - MVP)

Aplikasi kasir Flutter untuk UMKM dengan perintah suara berbahasa Indonesia.
Nama produk hasil ucapan dicocokkan dengan Levenshtein Distance, lalu masuk ke keranjang.

> Kode ini ditulis dari rancangan Tahap 2 dan belum dijalankan oleh penulisnya di perangkat.
> Ikuti langkah di bawah; bila ada galat kompilasi kecil, perbaiki lalu lanjut.

## Fitur MVP
Login (Firebase Auth), kelola produk (tambah, daftar, cari), keranjang, pembayaran,
transaksi tersimpan di Hive dan disinkronkan ke Firestore, riwayat, profil.
Perintah suara + Levenshtein (ambang 3). Tahap lanjut: dashboard, barcode, cetak struk, foto produk.

## LANGKAH PENGERJAAN (urut, sekitar 45-60 menit)

### A. Siapkan alat
1. Pasang Flutter SDK (flutter.dev), Android Studio, lalu jalankan `flutter doctor` sampai Android toolchain bertanda centang.
2. Siapkan HP Android (aktifkan Opsi Pengembang dan USB debugging) atau emulator dengan mikrofon.
3. Pasang Node.js, lalu: `npm install -g firebase-tools` dan `dart pub global activate flutterfire_cli`.

### B. Buat proyek dan salin kode
```bash
flutter create pos_voice_assistant
cd pos_voice_assistant
```
Dari folder zip ini, salin ke proyek baru tadi (timpa bila ditanya):
- folder `lib/`
- folder `test/`
- file `pubspec.yaml`
- file `.gitignore`, `firestore.rules`
Lalu: `flutter pub get`

### C. Siapkan Firebase
1. Buka console.firebase.google.com, Add project (mis. pos-voice-assistant).
2. Build > Authentication > Get started > aktifkan Email/Password.
3. Authentication > Users > Add user: buat akun uji, mis. `kasir@toko.id` / `123456`.
4. Build > Firestore Database > Create database (mulai dengan production mode), lalu tab Rules, tempel isi `firestore.rules`, Publish.
5. Di terminal proyek: `firebase login` lalu `flutterfire configure`
   (pilih project tadi, centang Android). Perintah ini menimpa `lib/firebase_options.dart` dengan file asli.

### D. Pengaturan Android
1. Buka `android_snippets/AndroidManifest_tambahan.xml`, salin isinya ke `android/app/src/main/AndroidManifest.xml`
   (izin RECORD_AUDIO dan INTERNET, serta blok `<queries>`).
2. Bila muncul galat minSdk, di `android/app/build.gradle` (atau `.kts`) set `minSdk = 23`.

### E. Jalankan
```bash
flutter analyze
flutter test          # uji Levenshtein, harus lulus
flutter run
```
Saat pertama menekan mikrofon, izinkan akses mikrofon.

### F. Isi data awal (lewat tab Produk, tombol +)
| Nama | Harga | Stok |
| --- | --- | --- |
| Indomie Goreng | 3500 | 40 |
| Teh Botol | 5000 | 24 |
| Gula Pasir 1 kg | 17000 | 12 |
| Kopi Sachet | 2000 | 60 |
| Minyak Goreng 1 L | 19000 | 8 |

## DAFTAR TANGKAPAN LAYAR (urutan sama dengan skenario uji T-01 sampai T-13)

| No | Layar yang di-screenshot | Cara menampilkannya |
| --- | --- | --- |
| 1 | Login kosong | Buka aplikasi |
| 2 | Galat email (T-01) | Isi email `abc`, password `123456`, ketuk Login |
| 3 | Galat password (T-02) | Email benar, password `12345` |
| 4 | Dashboard setelah login (T-03) | Login dengan akun uji |
| 5 | Form produk dengan galat (T-04, T-05) | Tab Produk, +, isi nama yang sama atau kosongkan harga, Simpan |
| 6 | Daftar produk berisi 5 item | Setelah data awal selesai |
| 7 | Lembar suara dengan hasil cocok (T-06) | Tab Kasir, Mikrofon, ketik `indomi goreng`, Cocokkan |
| 8 | Lembar suara tanpa kecocokan (T-07) | Ketik `sabun mandi`, Cocokkan |
| 9 | Keranjang berisi item + badge di tab Kasir | Pilih Indomie Goreng lalu Teh Botol |
| 10 | Galat uang kurang (T-09) | Bayar, Tunai, isi uang lebih kecil dari total, Selesai |
| 11 | Notifikasi "Transaksi tersimpan" (T-10) | Isi uang cukup, Selesai |
| 12 | Riwayat status belum sinkron (T-11) | Aktifkan mode pesawat, buat transaksi, buka Riwayat |
| 13 | Riwayat status tersinkron (T-12) | Matikan mode pesawat, Profil > Sinkronkan, buka Riwayat |
| 14 | Firestore Console berisi koleksi `products` dan `transactions` | Buka console.firebase.google.com |

Catat hasilnya di kolom "Hasil aktual" tabel pengujian (dokumen Tahap 2 dan 3, bagian 16).

## Git
```bash
git init
git add pubspec.yaml lib test .gitignore firestore.rules README.md android_snippets
git commit -m "feat: mvp pos voice assistant"
git branch -M main
git remote add origin <url-repositori-github>
git push -u origin main
```
Disarankan commit bertahap sesuai bagian 17 dokumen (satu commit per fitur).
`lib/firebase_options.dart` dan `google-services.json` tidak ikut terunggah (ada di `.gitignore`).

## Bila ada galat
- `DefaultFirebaseOptions` tidak terdefinisi / UnimplementedError: `flutterfire configure` belum dijalankan.
- Mikrofon tidak merespons: cek izin di Pengaturan HP, atau pakai kolom ketik di lembar suara.
- Versi paket bentrok: jalankan `flutter pub upgrade` atau sesuaikan nomor versi di `pubspec.yaml`.
- API `speech_to_text` berbeda pada versi lain: lihat dokumentasi paket untuk `listen(...)`.
