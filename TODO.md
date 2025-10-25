# 🧩 TODO – Flutter Game Project

## 🎯 Core Tasks

- [x] Setup Flame base class (`MyGame`)
- [x] Add player movement (drag/hold) + arena boundaries
- [x] Implement coin spawn and collection + scoring
- [x] Implement enemy spawn and collision + difficulty ramping
- [x] Add game state management (menu, playing, game_over) via overlays
- [x] Add HUD (score, pause)
- [x] Add audio (pickup/collide) + mute toggle

---

## 💰 Monetization

- [x] Integrate Google Mobile Ads SDK (Android/iOS)
- [x] Create `AdService` (init, preload, show/hide, logging)
- [x] Display adaptive banner ads on main menu
- [x] Show interstitial ads after Game Over
- [x] Add interstitial capping (max 1 per ±120s) + cooldown
- [x] Add rewarded ads for revive (max 1 per sesi)
- [x] Add rewarded ads for double coins (opsional, setelah run)
- [x] Implement daily reward via rewarded (maks 1/hari) + magnet buff
- [x] Implement GDPR/CCPA consent gating sebelum load iklan
- [x] Add Non-Personalized Ads toggle untuk privacy compliance
- [x] Add coin-based fallback untuk revive/double coins

---

## 🎨 UI / UX

- [x] Build main menu screen (Play, Daily Reward, Banner)
- [x] Build game over screen (score, restart, rewarded options)
- [x] Add custom buttons and icons
- [x] Add simple transition animation (fade/slide)
- [x] Add sound effects + volume icon state
- [x] Add magnet power-up visual feedback (flash overlay)
- [x] Optional: vibration (haptics)
- [x] Add Game Settings panel (debug, show GameConfig values)
- [x] Add comprehensive Dartdoc to all UI components (overlays, screens, components)

---

## 🧠 Data & Settings

- [x] Save high score with SharedPreferences
- [x] Add mute/unmute toggle (persist)
- [x] Add restart / pause system
- [x] Persist daily reward state (`last_daily_reward`)
- [x] Persist coins and pending magnet buff state
- [x] Add AppSettingsCubit untuk state management
- [x] Add haptics toggle (persist)
- [x] Instrumentation: session length, ad load/show rate, error codes
- [x] Logging: interstitial/rewarded load/show (eCPM placeholder bisa ditambah nanti)

---

## 🚀 Deployment

- [x] Create app icon & splash screen
- [x] Generate release build (AAB)
- [ ] Add privacy policy URL (store listing)

---

## 🔮 Future Enhancements

- [x] Tuning magnet buff duration dan cost
- [x] Reward breakdown UI (show coins + buff details)
- [x] Additional power-ups (speed boost, shield, etc.)
- [x] Achievement system
- [x] Leaderboard integration
- [x] Multiple character skins
- [x] Upload to Google Play Console
- [x] Test ads in release mode (test IDs → prod IDs)
- [x] Configure AdMob App ID & Unit IDs (Android/iOS)
- [x] Implement consent dialog (GDPR/CCPA) untuk wilayah terkait

---

## 🧩 Bonus Ideas

- [x] Add daily reward or login bonus (refine)
- [x] Add simple leaderboard (Supabase)

  - SUPABASE_URL = "https://rcobifucszhgibuclane.supabase.co"
  - SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjb2JpZnVjc3poZ2lidWNsYW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNjA3ODUsImV4cCI6MjA3NjczNjc4NX0.PC0jNhnWIEJa3wUDN25x1sWneCNB3tEyOEDaiQMH2Uw"
  - flutter run --dart-define SUPABASE_URL=https://rcobifucszhgibuclane.supabase.co --dart-define SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjb2JpZnVjc3poZ2lidWNsYW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNjA3ODUsImV4cCI6MjA3NjczNjc4NX0.PC0jNhnWIEJa3wUDN25x1sWneCNB3tEyOEDaiQMH2Uw

- [x] Add skins or themes
- [x] Add vibration feedback
- [x] Add difficulty modes (easy/normal/hard)
- [x] Add joystick controls

---

## ✅ Latest Changes

- [x] Fix magnet duration countdown to use seconds accumulator
- [x] Add safe overlay wrappers to avoid test environment asserts
- [x] Initialize MainMenu via `initialActiveOverlays` in `GameWidget`
- [x] Clean up lints (use super.key, Color.withValues, remove unused imports)
- [x] Update tests to avoid `pumpAndSettle` timeout
- [x] Add magnet glow around player during buff

---

## 📚 Documentation

- [x] Tambah komentar class/fungsi/blok di `LoggingService` & `AdService` sesuai project rules
- [x] Tambah dokumentasi pada `MyGame` (class & methods utama)

## 🎯 UI/UX Revamp Checklist

- [x] HUD overhaul: skor menonjol, timer jelas, ikon buff + progress
- [x] Game Over redesign: perbaikan logika tombol Revive dan Double Rewards
- [x] Main Menu redesign: Play/Skins/Leaderboard/Settings; banner bawah; quick actions Neumorphic compact; grid sekunder disembunyikan; dark barrier untuk kontras
- [x] Pause overlay: Resume/Restart/Quick Settings (audio/haptics) dengan backdrop semi-transparan
- [x] Theme tokens: palette warna, spacing scale, typography scale via ThemeData (AppTheme)
- [x] Icons & badges: komponen NeumorphicButton dan BokehBackground
- [x] Accessibility: kontras ≥ 4.5:1 (Main Menu improved via dark barrier), font ≥ 14, focus states keyboard (NeumorphicButton fokus/hover, font min 14)
- [x] Feedback polish: combo pop-up, tuning partikel, magnet glow subtle, durasi flash shield/obstacle (durasi disesuaikan; glow lebih subtle)
- [x] HUD performance: ValueListenable untuk update; minimalkan repaint dengan RepaintBoundary
- [x] Leaderboard UI polish: item ringkas (avatar initial, rank, score, waktu), submit dari Game Over
- [x] QA checklist: preview web/mobile, cek overlay (Main Menu, HUD, Pause, Game Over)

---

## ✅ Recent Updates (2025-01-17)

- [x] **HUD overhaul**: Skor prominent dengan glow, timer dinamis (hijau->kuning->merah), magnet buff visual
- [x] **Fix tombol Revive**: Selalu clickable saat game over karena obstacle, menampilkan pesan informatif
- [x] **Fix tombol Double Rewards**: Selalu tampil dan clickable, konsisten UX
- [x] **Tambah UI components**: BokehBackground, NeumorphicButton, AppTheme
- [x] **Code quality**: flutter analyze bersih, fix deprecation warnings withOpacity->withValues
- [x] **Git workflow**: Commit ke dev, push ke origin, siap untuk task berikutnya

## ✅ Recent Updates (2025-01-18)

- [x] **Fix tombol restart**: Perbaikan error Provider<LeaderboardService> dengan try-catch dan Provider.of
- [x] **Fix tombol pause**: Perbaikan bug yang menampilkan Main Menu saat pause dengan stabilisasi GameWidget

## 📝 Backlog

- [x] **Multi-language support**: id/en (Core screens integrated; audit remaining strings)
- [ ] **Add documentation to main class and methods in all files following #project_rules.md**
- [x] **Skins & themes improvement**
  - [x] **Draw skins from scratch using CustomPaint**
  - [x] **Draw themes from scratch using CustomPaint**
- [x] **Test ads rewards**: Unit tests added for cooldown/NPA; logic-only revive/daily return values verified. Manual device testing still pending.
- [x] **Improve UI for user mobile experience**
  - [x] Improve Option panel, remove controll that are not user used (e.g. Debug Logging)
  - [x] **Optimize layout for mobile**: Reduce padding, use compact controls, and improve responsiveness
  - [ ] **Joystick controls**: Show controls on touch screen dynamically (e.g. when player taps on screen)
