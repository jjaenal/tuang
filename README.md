# 🎮 Flutter + Flame: Endless Dodge & Collect (AdMob Ready)

Game mobile sederhana dengan **Flutter + Flame** yang dirancang untuk sesi singkat (30–60 detik), mudah dipahami, dan menarik untuk banyak pemain. Monetisasi menggunakan **Google AdMob**: Banner di menu, Interstitial saat Game Over, dan Rewarded untuk revive atau double coins.

---

## 🧱 Tech Stack
- **Flutter** (UI & logic)
- **Flame Engine** (game loop, komponen, collision)
- **Shared Preferences** (simpan skor & settings)
- **flutter_bloc** (opsional, state management)
- **Google Mobile Ads SDK** (monetisasi, Android/iOS)

> Catatan: Untuk preview cepat di web, ads tidak ditampilkan. Implementasi AdMob fokus pada Android/iOS.

---

## 🕹️ Konsep Game
- **Genre**: Endless Dodge & Collect (satu jari)
- **Kontrol**: drag/hold untuk menggerakkan karakter menghindari rintangan dan mengumpulkan koin
- **Loop**: Menu → Main → Game Over → (revive opsional) → Menu
- **Durasi Sesi**: ±45 detik rata-rata, meningkat seiring kesulitan
- **Daya Tarik**: sederhana, universal, cocok main sebentar

---

## 💰 Monetisasi (AdMob)
- **Banner (Adaptive)**: tampil di Main Menu, tidak mengganggu gameplay
- **Interstitial**: tampil setelah Game Over atau transisi level
  - Frekuensi: max 1 interstitial per ±120 detik, hanya saat layar transisi
  - Preload saat bermain; jika belum siap → skip
- **Rewarded**:
  - Revive sekali per sesi (setelah Game Over pertama)
  - Double coins opsional setelah run berakhir
  - Daily reward di menu (maks 1/hari) + magnet buff 12 detik
- **Non-Personalized Ads**: Toggle untuk privasi pengguna (GDPR compliance)

> Hindari spam iklan, beri tombol jelas, dan sediakan fallback jika iklan gagal dimuat.

---

## ⚙️ Instalasi & Menjalankan
1. Pastikan Flutter telah terpasang (disarankan Flutter 3.24+).
2. Masuk ke folder proyek:
   ```bash
   cd tuang
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Jalankan untuk preview web (tanpa ads):
   ```bash
   flutter run -d chrome
   ```
5. Jalankan di Android/iOS (ads aktif):
   ```bash
   flutter run
   ```

---

## 📂 Struktur Proyek
```
lib/
├── game/          → Flame game logic (komponen, collision, spawner)
├── ui/            → Main menu, Game Over, overlays
├── services/      → AdMob & SharedPrefs helpers
├── state/         → App settings & state management (Cubit)
└── main.dart      → Entry point + GameWidget overlays
```

---

## 🔧 Konfigurasi AdMob
- Buat App & Unit IDs di AdMob Console (Android/iOS)
- Ganti test IDs di `services/ad_service.dart` dengan milik Anda saat produksi
- Terapkan **consent** (GDPR/CCPA) bila diperlukan; gunakan dialog consent sebelum load iklan
- Preload `InterstitialAd` dan `RewardedAd` saat gameplay; tampilkan hanya pada transisi

### Test Ad Unit IDs
Gunakan ID test dari dokumentasi AdMob untuk pengembangan:
```dart
final bannerAdUnitId       = 'ca-app-pub-3940256099942544/6300978111';
final interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
final rewardedAdUnitId     = 'ca-app-pub-3940256099942544/5224354917';
```

---

## 🧠 Pengaturan & Data
- Simpan `high_score`, `is_muted`, `coins`, `last_daily_reward`, dan `pending_magnet_buff` dengan `SharedPreferences`
- Toggle mute/unmute dari HUD
- Toggle Non-Personalized Ads dari Main Menu
- Batasi revive rewarded: 1 kali per sesi
- Daily reward memberikan coins + magnet buff untuk run berikutnya
- Toggle Haptics di Main Menu (mobile only; web diabaikan otomatis; state dipersist)

---

## 🎯 Target Performa & UX
- **Orientasi**: Portrait
- **FPS**: Stabil 60
- **Durasi**: Sesi 30–60 detik
- **Optimasi**: object pooling komponen, collision ringan, asset minimal

---

## 🧪 Roadmap
- [x] Setup Flame + loop permainan dasar
- [x] Implement menu & game over (overlays)
- [x] Player movement & coin collect
- [x] Enemy spawn & collision
- [x] HUD skor, pause, life
- [x] Integrasi AdMob (banner, interstitial, rewarded)
- [x] Consent & Privacy policy
- [x] Daily reward dengan magnet buff
- [x] Non-Personalized Ads toggle
- [x] Coin-based fallback untuk revive/double coins
- [ ] Polishing UX + audio + vibration
- [ ] Rilis ke Google Play

---

## 🔐 Privacy & Compliance
- Sediakan **Privacy Policy URL** di store listing
- Tampilkan **consent dialog** (GDPR/CCPA) bila pengguna berasal dari wilayah terkait
- Toggle **Non-Personalized Ads** tersedia di Main Menu
- Patuh pada kebijakan konten dan iklan Google Play

---

## 📜 Lisensi
MIT © 2025 YourName

---

## ✏️ Perubahan Terbaru
- Developer: YourName
- File diubah:
  - `lib/services/logging_service.dart`: tambah komentar class/fungsi/blok untuk instrumentasi durasi sesi.
  - `lib/services/ad_service.dart`: tambah komentar class/fungsi serta penjelasan instrumentasi log iklan.
- Ringkas perubahan: dokumentasi internal ditingkatkan agar sesuai project rules (komentar pada class, fungsi, dan blok kode yang diubah), tanpa mengubah perilaku aplikasi.
