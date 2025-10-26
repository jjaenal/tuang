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
  - [x] improve option panel more eye-catching
  - [x] **Optimize layout for mobile**: Reduce padding, use compact controls, and improve responsiveness
  - [x] **Joystick controls**: Show controls on touch screen dynamically (e.g. when player taps on screen every where)
  - [x] Change selection skin/theme dialog to use bottom sheet

---

## 🚀 Advanced Features & Enhancements

### 🎮 Gameplay Enhancements

#### Boss Battles & Special Events
- [ ] **Boss System**: Implement periodic boss encounters (every 100 points)
  - [ ] Boss health bar and attack patterns
  - [ ] Special boss rewards (rare skins, bonus coins)
  - [ ] Boss defeat animations and celebrations
- [ ] **Special Events**: Time-limited gameplay modes
  - [ ] Double coin weekends
  - [ ] Speed challenge mode (faster gameplay)
  - [ ] Survival mode (no revives, high rewards)
  - [ ] Holiday-themed events with special obstacles/rewards

#### Advanced Power-ups & Mechanics
- [ ] **Combo System**: Chain collections for multiplier bonuses
  - [ ] Combo counter UI with streak visualization
  - [ ] Combo-based achievements and rewards
  - [ ] Perfect run bonuses (no hits taken)
- [ ] **Advanced Power-ups**:
  - [ ] Time Slow (bullet-time effect)
  - [ ] Coin Magnet Upgrade (larger radius, longer duration)
  - [ ] Ghost Mode (pass through obstacles briefly)
  - [ ] Score Multiplier (2x/3x for limited time)
  - [ ] Auto-Pilot (AI plays for 10 seconds)
- [ ] **Environmental Hazards**:
  - [ ] Moving platforms and rotating obstacles
  - [ ] Weather effects (rain affects visibility)
  - [ ] Dynamic arena size changes

#### Progression & Customization
- [ ] **Player Progression**: Level system with unlocks
  - [ ] XP gain from gameplay and achievements
  - [ ] Level-based rewards (skins, power-ups, coins)
  - [ ] Prestige system for advanced players
- [ ] **Advanced Customization**:
  - [ ] Skin editor (color picker, pattern overlay)
  - [ ] Trail effects for player movement
  - [ ] Custom arena themes (space, underwater, forest)
  - [ ] Particle effect customization

### 💎 Advanced Monetization

#### Premium Currency & IAP
- [ ] **Gems System**: Premium currency implementation
  - [ ] Gem shop with exclusive items
  - [ ] Gem-only skins and themes
  - [ ] Gem rewards from achievements
  - [ ] Daily gem login bonuses
- [ ] **In-App Purchases**:
  - [ ] Starter packs (coins + gems + power-ups)
  - [ ] VIP membership (ad-free, bonus rewards)
  - [ ] Skin bundles and theme packs
  - [ ] Power-up bundles
- [ ] **Battle Pass System**:
  - [ ] Seasonal battle pass with tiers
  - [ ] Free and premium tracks
  - [ ] Exclusive rewards and cosmetics
  - [ ] Battle pass XP from gameplay

#### Advanced Ad Integration
- [ ] **Rewarded Video Enhancements**:
  - [ ] Choose your reward (coins vs power-ups)
  - [ ] Ad-free gameplay sessions (30min premium)
  - [ ] Bonus chest after watching ads
- [ ] **Native Ads**: Integrate native ads in menus
- [ ] **Offerwall Integration**: Third-party offer completion
- [ ] **Cross-Promotion**: Promote other games

### 👥 Social Features

#### Friends & Community
- [ ] **Friends System**:
  - [ ] Add friends via username/code
  - [ ] Friends leaderboard and comparison
  - [ ] Send/receive gifts (coins, power-ups)
  - [ ] Friend activity feed
- [ ] **Guilds/Clans**:
  - [ ] Create and join guilds
  - [ ] Guild leaderboards and competitions
  - [ ] Guild chat and messaging
  - [ ] Guild rewards and bonuses
- [ ] **Social Sharing**:
  - [ ] Share high scores to social media
  - [ ] Screenshot sharing with custom frames
  - [ ] Achievement sharing
  - [ ] Invite friends with referral rewards

#### Competitive Features
- [ ] **Tournaments**:
  - [ ] Weekly tournaments with entry fees
  - [ ] Tournament brackets and elimination
  - [ ] Live tournament spectating
  - [ ] Tournament rewards and trophies
- [ ] **Challenges**:
  - [ ] Daily/weekly challenges
  - [ ] Friend challenges (1v1 score battles)
  - [ ] Community challenges
  - [ ] Challenge completion rewards

### 🔧 Technical Improvements

#### Performance & Optimization
- [ ] **Performance Monitoring**:
  - [ ] FPS counter and performance metrics
  - [ ] Memory usage optimization
  - [ ] Battery usage optimization
  - [ ] Crash reporting and analytics
- [ ] **Advanced Analytics**:
  - [ ] Player behavior tracking
  - [ ] A/B testing framework
  - [ ] Retention and engagement metrics
  - [ ] Revenue analytics and LTV tracking
- [ ] **Cloud Features**:
  - [ ] Cloud save synchronization
  - [ ] Cross-device progress sync
  - [ ] Backup and restore functionality
  - [ ] Offline mode with sync when online

#### Security & Quality
- [ ] **Anti-Cheat System**:
  - [ ] Score validation and verification
  - [ ] Suspicious activity detection
  - [ ] Secure leaderboard submissions
- [ ] **Quality Assurance**:
  - [ ] Automated testing pipeline
  - [ ] Device compatibility testing
  - [ ] Performance regression testing
  - [ ] Accessibility compliance testing

### 🌐 Platform Expansion

#### Multi-Platform Support
- [ ] **Desktop Optimization**:
  - [ ] Keyboard controls and shortcuts
  - [ ] Mouse support and hover states
  - [ ] Window resizing and fullscreen
  - [ ] Desktop-specific UI adjustments
- [ ] **Web Optimization**:
  - [ ] Progressive Web App (PWA) features
  - [ ] Web-specific performance optimizations
  - [ ] Browser compatibility testing
  - [ ] Web monetization strategies
- [ ] **Console Preparation**:
  - [ ] Controller support framework
  - [ ] TV-safe UI design
  - [ ] Console-specific features research

#### Advanced Distribution
- [ ] **Store Optimization**:
  - [ ] App Store Optimization (ASO)
  - [ ] Multiple store submissions (Play, App Store, Steam)
  - [ ] Store-specific feature compliance
- [ ] **Localization Expansion**:
  - [ ] Additional language support (Spanish, French, German, Japanese)
  - [ ] Cultural adaptation for different markets
  - [ ] Region-specific content and events
- [ ] **Marketing Integration**:
  - [ ] Deep linking for campaigns
  - [ ] Attribution tracking
  - [ ] Influencer collaboration features

### 🎯 Content & Engagement

#### Content Updates
- [ ] **Seasonal Content**:
  - [ ] Holiday-themed skins and obstacles
  - [ ] Seasonal achievements and rewards
  - [ ] Limited-time game modes
- [ ] **Regular Updates**:
  - [ ] Monthly content drops
  - [ ] New skin and theme releases
  - [ ] Balance updates and improvements
- [ ] **Community Features**:
  - [ ] Player-generated content support
  - [ ] Community voting on new features
  - [ ] Beta testing program for players

#### Retention & Engagement
- [ ] **Daily Engagement**:
  - [ ] Expanded daily quest system
  - [ ] Login streak rewards
  - [ ] Daily spin wheel or lottery
- [ ] **Long-term Engagement**:
  - [ ] Monthly login calendars
  - [ ] Milestone rewards (play 100 games, etc.)
  - [ ] Comeback bonuses for returning players

---

## 🎯 Implementation Priority

### Phase 1: Core Enhancements (Next 2-4 weeks)
1. Boss battles system
2. Advanced power-ups (Time Slow, Ghost Mode)
3. Gems premium currency
4. Basic IAP implementation

### Phase 2: Social & Competition (1-2 months)
1. Friends system
2. Tournament framework
3. Advanced leaderboards
4. Social sharing

### Phase 3: Platform & Scale (2-3 months)
1. Cloud save system
2. Advanced analytics
3. Multi-platform optimization
4. Localization expansion

### Phase 4: Advanced Features (3+ months)
1. Battle pass system
2. Guild/clan features
3. Advanced customization
4. Console preparation

---

## 📊 Success Metrics

### Engagement Metrics
- [ ] Daily Active Users (DAU) tracking
- [ ] Session length and frequency
- [ ] Feature adoption rates
- [ ] Player retention curves

### Monetization Metrics
- [ ] ARPU (Average Revenue Per User)
- [ ] LTV (Lifetime Value) tracking
- [ ] Conversion rates (free to paid)
- [ ] Ad revenue optimization

### Quality Metrics
- [ ] Crash-free session rate (>99.5%)
- [ ] App store ratings (>4.5 stars)
- [ ] Performance benchmarks
- [ ] User satisfaction surveys
