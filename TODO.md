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
- [ ] Integrate Google Mobile Ads SDK (Android/iOS)
- [x] Create `AdService` (init, preload, show/hide, logging)
- [x] Display adaptive banner ads on main menu
- [x] Show interstitial ads after Game Over
- [x] Add interstitial capping (max 1 per ±120s) + cooldown
- [x] Add rewarded ads for revive (max 1 per sesi)
- [x] Add rewarded ads for double coins (opsional, setelah run)
- [ ] Implement daily reward via rewarded (maks 1/hari)
- [x] Implement GDPR/CCPA consent gating sebelum load iklan

---

## 🎨 UI / UX
- [ ] Build main menu screen (Play, Daily Reward, Banner)
- [x] Build game over screen (score, restart, rewarded options)
- [ ] Add custom buttons and icons
- [ ] Add simple transition animation (fade/slide)
- [x] Add sound effects + volume icon state
- [ ] Optional: vibration (haptics)

---

## 🧠 Data & Settings
- [x] Save high score with SharedPreferences
- [x] Add mute/unmute toggle (persist)
- [x] Add restart / pause system
- [ ] Persist daily reward state (`last_daily_reward`)
- [ ] Instrumentation: session length, ad load/show rate, error codes
- [ ] Logging: interstitial/rewarded load/show, eCPM placeholder (dev log)

---

## 🚀 Deployment
- [ ] Create app icon & splash screen
- [ ] Generate release build (AAB)
- [ ] Add privacy policy URL (store listing)
- [ ] Upload to Google Play Console
- [ ] Test ads in release mode (test IDs → prod IDs)
- [ ] Configure AdMob App ID & Unit IDs (Android/iOS)
- [ ] Implement consent dialog (GDPR/CCPA) untuk wilayah terkait

---

## 🧩 Bonus Ideas
- [ ] Add daily reward or login bonus (refine)
- [ ] Add simple leaderboard (Firebase)
- [ ] Add skins or themes
- [ ] Add vibration feedback
- [ ] Add difficulty modes (easy/normal/hard)
