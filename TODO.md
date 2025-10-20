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
- [ ] Create app icon & splash screen
- [ ] Generate release build (AAB)
- [ ] Add privacy policy URL (store listing)

---

## 🔮 Future Enhancements
- [ ] Tuning magnet buff duration dan cost
- [x] Reward breakdown UI (show coins + buff details)
- [ ] Additional power-ups (speed boost, shield, etc.)
- [ ] Achievement system
- [ ] Leaderboard integration
- [ ] Multiple character skins
- [ ] Upload to Google Play Console
- [ ] Test ads in release mode (test IDs → prod IDs)
- [ ] Configure AdMob App ID & Unit IDs (Android/iOS)
- [ ] Implement consent dialog (GDPR/CCPA) untuk wilayah terkait

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
