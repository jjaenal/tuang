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
  /// Tuned: Reduced from 8.0 to 7.0 for more frequent magnet opportunities
  static const double magnetSpawnIntervalSec = 7.0;

  /// How often speed boost power-ups spawn (seconds)
  static const double speedBoostSpawnIntervalSec = 12.0;

  /// How often shield power-ups spawn (seconds)
  static const double shieldSpawnIntervalSec = 15.0;

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
  /// Tuned: Increased from 6.0 to 8.0 for better value
  static const double magnetPickupDurationSec = 8.0;

  /// Radius within which coins are attracted to player (pixels)
  /// Tuned: Increased from 120.0 to 140.0 for better collection
  static const double magnetPullRadius = 140.0;

  /// Strength of magnet attraction (pixels per second)
  /// Tuned: Increased from 220.0 to 280.0 for more satisfying pull
  static const double magnetPullStrength = 280.0;

  // === Speed Boost Power-up ===
  /// How long speed boost effect lasts when picked up (seconds)
  static const double speedBoostPickupDurationSec = 5.0;

  /// Speed multiplier during speed boost power-up (1.0 = normal, 1.4 = 40% faster)
  static const double speedBoostPowerUpMultiplier = 1.4;

  // === Shield Power-up ===
  /// How long shield protection lasts when picked up (seconds)
  static const double shieldPickupDurationSec = 8.0;

  // === Combo System ===
  /// Time window to maintain combo multiplier (seconds)
  static const double comboWindowSec = 2.0;

  /// How many coins needed to increase combo multiplier by 1
  static const int coinsPerComboLevel = 3;

  // === Revive & Rewards ===
  /// Maximum revives allowed per session
  static const int maxRevivesPerSession = 1;

  /// Default daily magnet buff duration (seconds)
  /// Tuned: Increased from 12 to 15 for better daily reward value
  static const int defaultDailyMagnetBuffSec = 15;

  /// Maximum daily magnet buff duration (seconds)
  /// Tuned: Increased from 15 to 20 for rewarded ad incentive
  static const int maxDailyMagnetBuffSec = 20;

  /// Daily reward coins amount
  /// Tuned: Increased from 25 to 30 for better progression
  static const int dailyRewardCoins = 30;

  /// Cost in coins for revive fallback
  static const int reviveCostCoins = 50;

  /// Cost in coins for double coins fallback
  static const int doubleCoinsCoins = 50;

  // === Economy ===
  /// Estimated value (in coins) per second of magnet buff for breakdown UI
  /// Tuned: Increased from 1 to 2 coins per second for better perceived value
  static const int magnetBuffValuePerSecondCoins = 2;

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
