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
- [ ] Optional: vibration (haptics)

---

## 🧠 Data & Settings
- [x] Save high score with SharedPreferences
- [x] Add mute/unmute toggle (persist)
- [x] Add restart / pause system
- [x] Persist daily reward state (`last_daily_reward`)
- [x] Persist coins and pending magnet buff state
- [x] Add AppSettingsCubit untuk state management
- [ ] Instrumentation: session length, ad load/show rate, error codes
- [ ] Logging: interstitial/rewarded load/show, eCPM placeholder (dev log)

---

## 🚀 Deployment
- [ ] Create app icon & splash screen
- [ ] Generate release build (AAB)
- [ ] Add privacy policy URL (store listing)

---

## 🔮 Future Enhancements
- [ ] Tuning magnet buff duration dan cost
- [ ] Reward breakdown UI (show coins + buff details)
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
- [ ] Add vibration feedback
- [ ] Add difficulty modes (easy/normal/hard)
