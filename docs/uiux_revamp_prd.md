# UI/UX Revamp PRD

## Ringkasan & Tujuan
- Meningkatkan kejelasan, responsivitas, dan feedback visual permainan.
- Memperkuat momen rewarding (Game Over, Leaderboard) dan navigasi yang jelas.
- Menjaga performa dan aksesibilitas di web dan mobile.

## Prinsip Desain
- Arcade-modern, minimal-informative, responsive-first.
- Hierarki visual yang jelas untuk skor, timer, dan status buff.
- Konsistensi gaya (pill UI, ikon, spacing, typography).

## Global Requirements
- Responsive: `SafeArea` + `LayoutBuilder`. Grid 2 kolom (mobile), 4+ (desktop) untuk list seperti skins/achievements.
- Aksesibilitas: kontras ≥ 4.5:1, ukuran font ≥ 14, focus states untuk keyboard/web.
- Performa: gunakan `ValueListenableBuilder`, minimalkan rebuild, gunakan `const` bila memungkinkan.
- Theme tokens: siapkan palette warna, spacing scale, typography scale via `ThemeData` (akan diimplementasi di fase terpisah).

---

## Fitur 1: HUD Overhaul
- Komponen:
  - Score pill (ikon `star`, angka besar, bold).
  - Time pill (ikon `timer`, angka besar, bold).
  - Magnet indicator (progress bar + detik tersisa).
  - Combo pill.
  - Controls (Pause/Resume, Audio toggle).
  - Debug pill (conditional saat `LoggingService.enabled`).
- State/UI Sources:
  - `MyGame`: `scoreVN`, `timeVN`, `magnetVN`, `magnetSecondsLeft`, `comboVN`.
  - `AppSettingsCubit`: `paused`, `audioOn`, `coins`.
- Interaksi:
  - Pause/Resume mengubah `AppSettingsCubit.paused`.
  - Audio toggle mengubah `AppSettingsCubit.audioOn`.
- Acceptance Criteria (AC):
  - Score & Time tampil menonjol (ukuran ≥ 18, bold) dengan ikon.
  - Magnet bar lebar cukup (≥ 100px) dan progres konsisten 0..1.
  - Tidak ada overlap antar pill di resolusi mobile & desktop.
  - Tidak ada penurunan performa (frame tetap stabil saat update VN).

Status: sebagian sudah diterapkan dan di-commit (`b111f5f`).

---

## Fitur 2: Game Over Redesign
- Komponen:
  - Title, Score, Best Score.
  - Reward breakdown card (ikon + angka): base score, bonus (double coins, magnet usage), total coins yang akan disetor.
  - CTA: `Retry`, `Double Coins` (jika tersedia), `Leaderboard`, `Skins`, `Share` (opsional), `Revive` (1x bila tersedia).
- State/UI Sources:
  - `MyGame`: `scoreVN`, `baseScoreAtGameOver`, `bestScore`, `doubleCoinsUsed`, `magnetUsedThisRun`, `rewardDeposited`, `reviveAvailable`.
- Interaksi:
  - Retry → `MyGame.startGame()`.
  - Double Coins → deposit reward, update `doubleCoinsUsed`.
  - Leaderboard → buka overlay leaderboard.
  - Skins → kembali ke Main Menu / Skins.
  - Revive → `MyGame.revive()` (sekali per sesi).
- AC:
  - Reward breakdown mudah dipahami dengan ikon dan label.
  - Tombol CTA jelas, urutan: Retry, Double, Leaderboard, Skins.
  - Revive muncul hanya saat tersedia, disabled atau hidden jika tidak.
  - Tidak mengganggu state existing (idempotent saat game sudah tidak playing).

---

## Fitur 3: Main Menu Redesign
- Komponen:
  - Kartu utama `Play` (primary CTA).
  - Kartu `Skins`, `Achievements`, `Leaderboard`, `Settings`.
  - Area banner/announcement (opsional).
- State/UI Sources:
  - `MyGame.overlays` dan builder map di `main.dart`.
  - `AppSettingsCubit` untuk preferensi (mis. audio/haptics).
- Interaksi:
  - Play → masuk ke sesi game (`startGame()` + tampilkan HUD).
  - Skins/Achievements/Leaderboard/Settings → buka overlay/layar terkait.
- AC:
  - Navigasi jelas dan mudah dengan focus state untuk keyboard.
  - Layout responsif: dua baris pada mobile, grid seimbang pada desktop.

---

## Fitur 4: Leaderboard UI Polish
- Komponen:
  - Pencarian (input), daftar entri dengan avatar initial, rank, score, waktu.
  - Highlight current player dan last submitted.
- State/UI Sources:
  - `LeaderboardService`, data entri, state "current" dan "last submitted" (jika ada).
- Interaksi:
  - Submit dari Game Over.
  - Filter dengan search.
- AC:
  - Konsistensi visual (pill/border, warna kontras).
  - Item padat dan mudah dipindai, highlight top 3.

---

## Fitur 5: Pause Overlay
- Komponen:
  - Backdrop semi-transparan.
  - Tombol: Resume, Restart.
  - Quick Settings: Audio, Haptics (opsional).
- State/UI Sources:
  - `AppSettingsCubit.paused`.
- Interaksi:
  - Resume/Restart sesuai state game.
  - Toggle audio/haptics.
- AC:
  - Overlay aman (tidak crash), `overlay_safe_test` tetap pass.

---

## Aksesibilitas & Performa
- Aksesibilitas:
  - Kontras teks minimal 4.5:1.
  - Ukuran font minimal 14; tombol minimal tinggi 36.
  - Focus ring/focus state untuk elemen interaktif di web.
- Performa:
  - Batasi rebuild: gunakan `ValueListenableBuilder` dan `const`.
  - Hindari operasi berat pada frame UI.

---

## QA & Validasi
- Preview web di `http://localhost:5173/` untuk setiap perubahan UI.
- Jalankan `flutter analyze` dan `flutter test` setiap commit (mengikuti project rules).
- Cek overlay flow: Main Menu → HUD → Pause → Game Over → Leaderboard.

---

## Roadmap & Milestones
- M1 HUD Overhaul (done sebagian, lanjut finalisasi/polish) — 1 commit.
- M2 Game Over Redesign — 1–2 commits.
- M3 Main Menu Redesign — 1–2 commits.
- M4 Leaderboard UI Polish — 1 commit.
- M5 Pause Overlay + QA — 1 commit.

Setiap milestone mengikuti AC, lint/test/preview, commit message sesuai guidelines.