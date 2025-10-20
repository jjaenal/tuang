/// Centralized game configuration constants for easy tuning and maintenance.
///
/// This class contains all game balance parameters, spawn rates, durations,
/// and other tunable values that affect gameplay mechanics.
class GameConfig {
  // === Privacy & Consent ===
  /// Whether the app should always require consent dialog (GDPR/CCPA) before enabling ads
  /// Set to true for safety; can be adjusted per-region in future.
  static const bool alwaysRequireConsent = true;

  // === Spawn Intervals ===
  /// How often coins spawn (seconds)
  static const double coinSpawnIntervalSec = 1.5;

  /// How often obstacles spawn (seconds)
  static const double obstacleSpawnIntervalSec = 2.5;

  /// How often magnet power-ups spawn (seconds)
  static const double magnetSpawnIntervalSec = 8.0;

  // === Session Settings ===
  /// Default session length in seconds
  static const double defaultSessionLengthSec = 30.0;

  // === Player Movement ===
  /// Base player movement speed (pixels per second)
  static const double playerBaseSpeed = 80.0;

  /// Speed boost multiplier when picking up coins
  static const double speedBoostMultiplier = 0.6; // +60% speed

  /// Duration of speed boost effect (seconds)
  static const double speedBoostDurationSec = 0.5;

  // === Magnet Power-up ===
  /// How long magnet effect lasts when picked up (seconds)
  static const double magnetPickupDurationSec = 6.0;

  /// Radius within which coins are attracted to player (pixels)
  static const double magnetPullRadius = 120.0;

  /// Strength of magnet attraction (pixels per second)
  static const double magnetPullStrength = 220.0;

  // === Combo System ===
  /// Time window to maintain combo multiplier (seconds)
  static const double comboWindowSec = 2.0;

  /// How many coins needed to increase combo multiplier by 1
  static const int coinsPerComboLevel = 3;

  // === Revive & Rewards ===
  /// Maximum revives allowed per session
  static const int maxRevivesPerSession = 1;

  /// Default daily magnet buff duration (seconds)
  static const int defaultDailyMagnetBuffSec = 12;

  /// Maximum daily magnet buff duration (seconds)
  static const int maxDailyMagnetBuffSec = 15;

  /// Daily reward coins amount
  static const int dailyRewardCoins = 25;

  /// Cost in coins for revive fallback
  static const int reviveCostCoins = 50;

  /// Cost in coins for double coins fallback
  static const int doubleCoinsCoins = 50;

  // === Economy ===
  /// Estimated value (in coins) per second of magnet buff for breakdown UI
  static const int magnetBuffValuePerSecondCoins = 1;

  /// Compute estimated coin value for a magnet buff of [seconds].
  /// Clamps to [maxDailyMagnetBuffSec]. Returns non-negative integer.
  static int magnetBuffValueCoins(int seconds) {
    if (seconds <= 0) return 0;
    final clamped =
        seconds < 0
            ? 0
            : (seconds > maxDailyMagnetBuffSec
                ? maxDailyMagnetBuffSec
                : seconds);
    return clamped * magnetBuffValuePerSecondCoins;
  }

  // === Visual Effects ===
  /// Screen shake intensity for coin pickup
  static const double coinShakeIntensity = 6.0;

  /// Screen shake duration for coin pickup (seconds)
  static const double coinShakeDurationSec = 0.12;

  /// Screen shake intensity for collision
  static const double collisionShakeIntensity = 10.0;

  /// Screen shake duration for collision (seconds)
  static const double collisionShakeDurationSec = 0.2;

  /// Screen shake intensity for revive
  static const double reviveShakeIntensity = 8.0;

  /// Screen shake duration for revive (seconds)
  static const double reviveShakeDurationSec = 0.18;

  // === Obstacle Settings ===
  /// Minimum obstacle speed (pixels per second)
  static const double obstacleMinSpeed = 80.0;

  /// Maximum additional obstacle speed (pixels per second)
  static const double obstacleMaxSpeedBonus = 140.0;

  // === Particle Effects ===
  /// Number of particles to spawn on coin pickup
  static const int coinParticleCount = 12;

  /// Minimum particle speed (pixels per second)
  static const double particleMinSpeed = 80.0;

  /// Maximum additional particle speed (pixels per second)
  static const double particleMaxSpeedBonus = 120.0;
}
