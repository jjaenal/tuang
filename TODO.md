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
- [ ] Add daily reward or login bonus (refine)
- [ ] Add simple leaderboard (Firebase)
- [ ] Add skins or themes
- [x] Add vibration feedback
- [ ] Add difficulty modes (easy/normal/hard)

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
- [ ] HUD overhaul: skor menonjol, timer jelas, ikon buff + progress
- [ ] Game Over redesign: reward breakdown pakai ikon + CTA (Retry/Double/Leaderboard/Skins)
- [ ] Main Menu redesign: kartu Play/Skins/Achievements/Leaderboard/Settings + posisi banner
- [x] Pause overlay: Resume/Restart/Quick Settings (audio/haptics) dengan backdrop semi-transparan
- [ ] Theme tokens: palette warna, spacing scale, typography scale via ThemeData
- [ ] Icons & badges: ikon buff, badge achievement, tooltip label untuk web focus
- [ ] Responsive layout: SafeArea + LayoutBuilder; grid skins/achievements 2 kolom mobile, 4+ desktop
- [ ] Accessibility: kontras ≥ 4.5:1, font ≥ 14, focus states untuk keyboard
- [ ] Feedback polish: combo pop-up, tuning partikel, magnet glow subtle, durasi flash shield/obstacle
- [ ] HUD performance: ValueListenable untuk update; minimalkan rebuild berat
- [ ] Leaderboard UI polish: item ringkas (avatar initial, rank, score, waktu), submit dari Game Over
- [ ] QA checklist: preview web/mobile, cek overlay (Main Menu, HUD, Pause, Game Over)
