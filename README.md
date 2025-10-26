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

## 🚀 Uji Iklan di Mode Rilis (Android/iOS)

### Manajemen Secret (tanpa commit)

- **Android App ID**: set di `android/gradle.properties` (atau `~/.gradle/gradle.properties`)
  ```properties
  ADMOB_APP_ID_ANDROID=ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy
  ```
  App ID akan diinjeksikan ke `AndroidManifest.xml` via `@string/admob_app_id`.
- **iOS App ID**: edit `ios/Runner/Info.plist`
  ```xml
  <key>GADApplicationIdentifier</key>
  <string>ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy</string>
  ```
- **Unit IDs**: gunakan `--dart-define` saat build/run (tidak disimpan di repo)
  - Android: `ADMOB_BANNER_ANDROID`, `ADMOB_INTERSTITIAL_ANDROID`, `ADMOB_REWARDED_ANDROID`
  - iOS: `ADMOB_BANNER_IOS`, `ADMOB_INTERSTITIAL_IOS`, `ADMOB_REWARDED_IOS`
- **Privacy Policy URL (dialog consent)**: set via `--dart-define=PRIVACY_URL=https://yourdomain.com/privacy`
- **Android Permissions**: `INTERNET` dan `ACCESS_NETWORK_STATE` diperlukan; sudah ditambahkan di manifest rilis (`android/app/src/main/AndroidManifest.xml`).

### Build Rilis

- **Android APK**
  ```bash
  flutter build apk --release \
    --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-xxx/zzz
  ```
- **Android AAB** (untuk Play Store)
  ```bash
  flutter build appbundle \
    --dart-define=ADMOB_BANNER_ANDROID=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_INTERSTITIAL_ANDROID=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_REWARDED_ANDROID=ca-app-pub-xxx/zzz \
    --dart-define=PRIVACY_URL=https://yourdomain.com/privacy
  ```
- **iOS (tanpa codesign, untuk validasi)**
  ```bash
  flutter build ios --no-codesign \
    --dart-define=ADMOB_BANNER_IOS=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_INTERSTITIAL_IOS=ca-app-pub-xxx/zzz \
    --dart-define=ADMOB_REWARDED_IOS=ca-app-pub-xxx/zzz \
    --dart-define=PRIVACY_URL=https://yourdomain.com/privacy
  ```

### Verifikasi Fungsional

- **Banner** tampil di Main Menu.
- **Interstitial** muncul setelah Game Over jika preload sukses dan tidak melanggar cooldown.
- **Rewarded** untuk Revive dan Daily Reward; pastikan callback reward dieksekusi.
- **Non-Personalized Ads**: toggle tersedia di Main Menu.

### Catatan Build Android (NDK)

- Jika muncul peringatan versi NDK tidak cocok, set:
  ```kotlin
  // android/app/build.gradle.kts
  android {
      ndkVersion = "27.0.12077973"
  }
  ```

### Produksi

- Ganti App ID iOS di `Info.plist` dan set App ID Android via `gradle.properties` (bukan commit).
- Unit ID jangan dikomit; selalu pasang via `--dart-define`.
- Pastikan consent + privacy policy sesuai kebijakan Google Play.

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

### 2025-01-17 - UI/UX Revamp: Fix Tombol Game Over

- **Developer**: Assistant AI
- **Branch**: `feature/uiux-revamp` → `dev`
- **Files Modified**: `lib/ui/game_over.dart`
- **Changes**:
  - Perbaikan logika tombol **Revive**: selalu clickable saat game over karena obstacle, menampilkan pesan informatif jika revive/ads tidak tersedia
  - Perbaikan logika tombol **Double Rewards**: selalu tampil dan clickable, konsisten UX pattern
  - Tambah UI components: `BokehBackground`, `NeumorphicButton`, `AppTheme`
- **Impact**: Meningkatkan UX dengan tombol yang lebih responsif dan informatif
- **Testing**: ✅ `flutter analyze` bersih, ✅ 29/29 tests passed, ✅ Manual testing via web preview

### Sebelumnya

- **Developer**: YourName
- **Files Modified**: `lib/services/logging_service.dart`, `lib/services/ad_service.dart`
- **Changes**: Dokumentasi internal ditingkatkan sesuai project rules (komentar class/fungsi/blok)
- **Impact**: Tidak mengubah perilaku aplikasi, hanya meningkatkan maintainability

## 🚀 Advanced Features & Enhancements yang Ditambahkan:

### 🎮 Gameplay Enhancements

- Boss Battles & Special Events : Boss encounters, seasonal events, survival mode
- Advanced Power-ups : Time Slow, Ghost Mode, Auto-Pilot, Score Multiplier
- Combo System : Chain collections, streak visualization, perfect run bonuses
- Player Progression : Level system, XP, prestige system

### 💎 Advanced Monetization

- Gems System : Premium currency dengan exclusive items
- In-App Purchases : Starter packs, VIP membership, skin bundles
- Battle Pass System : Seasonal tiers dengan free/premium tracks
- Advanced Ad Integration : Rewarded video enhancements, native ads

### 👥 Social Features

- Friends System : Add friends, leaderboard comparison, gift exchange
- Guilds/Clans : Guild creation, competitions, chat, rewards
- Tournaments : Weekly tournaments, brackets, live spectating
- Social Sharing : High score sharing, achievement sharing

### 🔧 Technical Improvements

- Performance Monitoring : FPS counter, memory optimization, crash reporting
- Advanced Analytics : Player behavior tracking, A/B testing, LTV tracking
- Cloud Features : Cloud save sync, cross-device progress, offline mode
- Security : Anti-cheat system, score validation

### 🌐 Platform Expansion

- Multi-Platform Support : Desktop optimization, web PWA, console preparation
- Advanced Distribution : ASO, multiple store submissions
- Localization Expansion : Additional languages, cultural adaptation

### 🎯 Implementation Priority

- Phase 1 (2-4 weeks): Boss battles, advanced power-ups, gems system
- Phase 2 (1-2 months): Social features, tournaments
- Phase 3 (2-3 months): Cloud save, analytics, multi-platform
- Phase 4 (3+ months): Battle pass, guilds, advanced customization
