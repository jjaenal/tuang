import 'dart:math';
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'player.dart';
import 'coin.dart';
import 'obstacle.dart';
import 'magnet.dart';
import 'effects.dart';
import 'speed_boost.dart';
import 'shield.dart';
import 'game_config.dart';
import '../models/achievement.dart';
import '../models/character_skin.dart';
import '../services/achievement_service.dart';
import '../state/pref_keys.dart';
import '../services/logging_service.dart';

/// [MyGame] is the main FlameGame driving the arcade session.
///
/// Manages overlays (MainMenu, Hud, GameOver), spawns entities, and
/// updates game mechanics like magnet pull, combo, timers, and collisions.
/// Input is fed via drag/keyboard from `main.dart`. This class exposes
/// ValueNotifiers for HUD and coordinates achievements via `AchievementService`.
class MyGame extends FlameGame {
  // Overlay keys
  static const String overlayMainMenu = 'MainMenu';
  static const String overlayHud = 'Hud';
  static const String overlayGameOver = 'GameOver';

  // UI state
  final ValueNotifier<int> scoreVN = ValueNotifier<int>(0);
  final ValueNotifier<int> timeVN = ValueNotifier<int>(0);
  final ValueNotifier<double> magnetVN = ValueNotifier<double>(0.0);
  final ValueNotifier<int> comboVN = ValueNotifier<int>(1);

  // Input
  Vector2 inputDir = Vector2.zero();
  double playerSpeedMultiplier = 1.0;

  // Game state flags
  bool isPlaying = false;
  int bestScore = 0;
  int baseScoreAtGameOver = 0;
  bool doubleCoinsUsed = false;
  bool magnetUsedThisRun = false;
  bool rewardDeposited = false;

  bool reviveAvailable = true;
  int reviveCount = 0;
  int coinsPicked = 0;
  int magnetsPicked = 0;

  // Timing
  double elapsed = 0.0;
  final int sessionLength = 30; // seconds

  // Magnet buff state
  int magnetSecondsLeft = 0;
  int _magnetTotalSeconds = 0;
  double _magnetSecAccumulator = 0.0;

  // Gameplay entities and timers
  late final Player player;
  final Random _rng = Random();
  double _coinTimer = 0.0;
  double _obstacleTimer = 0.0;
  double _magnetTimer = 0.0;
  double _speedBoostTimer = 0.0;
  double _shieldTimer = 0.0;
  // Variabel untuk efek power-up
  double _speedBoostLeft = 0.0;
  double _comboWindowLeft = 0.0;
  int _coinsSinceLastCombo = 0;

  // Power-up status
  double speedBoostSecondsLeft = 0.0;
  double shieldSecondsLeft = 0.0;

  // Achievements
  final AchievementService _achievementService = AchievementService.I;

  // Visual effects
  MagnetGlow? _magnetGlow;
  SpeedBoostGlow? _speedBoostGlow;
  ShieldGlow? _shieldGlow;

  @override
  Future<void> onLoad() async {
    // Add background color untuk debugging
    add(
      RectangleComponent(
        size: Vector2(2000, 2000), // Large background
        paint: Paint()..color = const Color(0xFF2E2E2E), // Dark gray
        position: Vector2.zero(),
      ),
    );

    timeVN.value = sessionLength;
    
    // Dapatkan skin aktif dari AppSettingsCubit
    final activeSkin = await _getActiveSkin();
    player = Player(skin: activeSkin);
    await add(player);
  }
  
  // Mendapatkan skin aktif dari AppSettingsCubit
  Future<CharacterSkin> _getActiveSkin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final skinId = prefs.getString(PrefKeys.activeSkinId) ?? 'default';
      return CharacterSkin.defaultSkins.firstWhere(
        (skin) => skin.id == skinId,
        orElse: () => CharacterSkin.defaultSkins.first,
      );
    } catch (e) {
      LoggingService.log('active_skin_error', fields: {'error': e.toString()});
      return CharacterSkin.defaultSkins.first;
    }
  }

  /// Starts a new game session: resets timers/state, cleans entities,
  /// switches HUD overlay, and increments starting achievements. Also
  /// consumes any pending magnet buff from SharedPreferences.
  void startGame() {
    isPlaying = true;
    elapsed = 0.0;
    scoreVN.value = 0;
    timeVN.value = sessionLength;
    reviveAvailable = true;
    rewardDeposited = false;
    doubleCoinsUsed = false;
    magnetUsedThisRun = false;
    magnetSecondsLeft = 0;
    _magnetTotalSeconds = 0;
    magnetVN.value = 0.0;
    comboVN.value = 1;
    _coinTimer = 0.0;
    _obstacleTimer = 0.0;
    _magnetTimer = 0.0;
    _speedBoostLeft = 0.0;
    _comboWindowLeft = 0.0;
    _coinsSinceLastCombo = 0;
    _magnetSecAccumulator = 0.0;
    _magnetGlow = null;

    // Cleanup residual entities
    for (final c in children.whereType<Coin>().toList()) {
      c.removeFromParent();
    }
    for (final o in children.whereType<Obstacle>().toList()) {
      o.removeFromParent();
    }
    for (final m in children.whereType<MagnetPowerUp>().toList()) {
      m.removeFromParent();
    }
    for (final s in children.whereType<SpeedBoostPowerUp>().toList()) {
      s.removeFromParent();
    }
    for (final sh in children.whereType<ShieldPowerUp>().toList()) {
      sh.removeFromParent();
    }
    for (final g in children.whereType<MagnetGlow>().toList()) {
      g.removeFromParent();
    }

    overlays.remove(overlayMainMenu);
    _safeAddOverlay(overlayHud);

    // Achievement: game start counters
    _achievementService.incrementProgress(AchievementType.firstGame);
    _achievementService.incrementProgress(AchievementType.play10Games);
    _achievementService.incrementProgress(AchievementType.play50Games);

    // Consume pending magnet buff asynchronously (for tests)
    Future(() async {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getInt('pref_pendingMagnetBuffSec') ?? 0;
      if (pending > 0) {
        magnetSecondsLeft = pending;
        _magnetTotalSeconds = pending;
        _magnetSecAccumulator = 0.0;
        magnetUsedThisRun = true;
        magnetsPicked += 1;
        magnetVN.value = 1.0;
        await prefs.setInt('pref_pendingMagnetBuffSec', 0);
        _achievementService.updateProgress(AchievementType.useMagnet, 1);
      }
    });
  }

  @override
  /// Updates core mechanics each frame with [dt] seconds.
  ///
  /// Handles session timer, magnet countdown via 1-second accumulator,
  /// speed boost decay, spawns, coin attraction under magnet, pickups,
  /// combo window, collisions, and session end.
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    // Elapsed time accumulation
    elapsed += dt;

    // Countdown remaining time
    final remaining = (sessionLength - elapsed).ceil();
    timeVN.value = remaining > 0 ? remaining : 0;

    // Magnet countdown
    if (magnetSecondsLeft > 0) {
      _magnetSecAccumulator += dt;
      while (_magnetSecAccumulator >= 1.0 && magnetSecondsLeft > 0) {
        magnetSecondsLeft -= 1;
        _magnetSecAccumulator -= 1.0;
      }
      if (_magnetTotalSeconds > 0) {
        magnetVN.value = magnetSecondsLeft / _magnetTotalSeconds;
      }
      // ensure glow is present while magnet is active
      if (_magnetGlow == null) {
        final glow = MagnetGlow(target: player);
        _magnetGlow = glow;
        add(glow);
      }
    } else {
      magnetVN.value = 0.0;
      _magnetSecAccumulator = 0.0;
      // remove glow when magnet ends
      if (_magnetGlow != null) {
        _magnetGlow!.removeFromParent();
        _magnetGlow = null;
      }
    }

    // Speed boost countdown
    if (_speedBoostLeft > 0) {
      _speedBoostLeft -= dt;
      if (_speedBoostLeft <= 0) {
        // fallback ke power-up boost jika masih aktif
        playerSpeedMultiplier =
            speedBoostSecondsLeft > 0
                ? GameConfig.speedBoostPowerUpMultiplier
                : 1.0;
        if (_speedBoostGlow != null && speedBoostSecondsLeft <= 0) {
          _speedBoostGlow?.removeFromParent();
          _speedBoostGlow = null;
        }
      } else if (_speedBoostGlow == null) {
        final glow = SpeedBoostGlow(target: player);
        _speedBoostGlow = glow;
        add(glow);
      }
    }

    // Shield countdown
    if (shieldSecondsLeft > 0) {
      shieldSecondsLeft -= dt;
      if (shieldSecondsLeft <= 0) {
        shieldSecondsLeft = 0;
        if (_shieldGlow != null) {
          _shieldGlow?.removeFromParent();
          _shieldGlow = null;
        }
      } else if (_shieldGlow == null) {
        final glow = ShieldGlow(target: player);
        _shieldGlow = glow;
        add(glow);
      }
    }

    // Spawn timers
    _coinTimer += dt;
    _obstacleTimer += dt;
    _magnetTimer += dt;
    _speedBoostTimer += dt;
    _shieldTimer += dt;
    if (_coinTimer >= GameConfig.coinSpawnIntervalSec) {
      _coinTimer = 0.0;
      _spawnCoin();
    }
    if (_obstacleTimer >= GameConfig.obstacleSpawnIntervalSec) {
      _obstacleTimer = 0.0;
      _spawnObstacle();
    }
    if (_magnetTimer >= GameConfig.magnetSpawnIntervalSec) {
      _magnetTimer = 0.0;
      _spawnMagnet();
    }
    if (_speedBoostTimer >= GameConfig.speedBoostSpawnIntervalSec) {
      _speedBoostTimer = 0.0;
      _spawnSpeedBoost();
    }
    if (_shieldTimer >= GameConfig.shieldSpawnIntervalSec) {
      _shieldTimer = 0.0;
      _spawnShield();
    }

    // Magnet attraction & coin pickup
    for (final coin in children.whereType<Coin>().toList()) {
      // Attract coins when magnet is active
      if (magnetSecondsLeft > 0) {
        final delta = player.position - coin.position;
        final dist = delta.length;
        if (dist < GameConfig.magnetPullRadius) {
          final dir = dist == 0 ? Vector2.zero() : (delta / dist);
          coin.position += dir * GameConfig.magnetPullStrength * dt;
        }
      }
      // Pickup check
      if (_overlap(player, coin)) {
        coin.removeFromParent();
        onCoinPicked();
        _speedBoostLeft = GameConfig.speedBoostDurationSec;
        playerSpeedMultiplier = 1.0 + GameConfig.speedBoostMultiplier;

        // Combo logic
        if (_comboWindowLeft <= 0) {
          _comboWindowLeft = GameConfig.comboWindowSec;
          _coinsSinceLastCombo = 0;
          comboVN.value = 1;
        }
        _coinsSinceLastCombo += 1;
        if (_coinsSinceLastCombo >= GameConfig.coinsPerComboLevel) {
          comboVN.value += 1;
          _coinsSinceLastCombo = 0;
        }

        add(PopEffect(position: player.position.clone()));
        add(FloatingText(position: player.position.clone()));
      }
    }

    // Combo window countdown
    if (_comboWindowLeft > 0) {
      _comboWindowLeft -= dt;
      if (_comboWindowLeft <= 0) {
        comboVN.value = 1;
      }
    }

    // Magnet pickup
    for (final mag in children.whereType<MagnetPowerUp>().toList()) {
      if (_overlap(player, mag)) {
        mag.removeFromParent();
        magnetSecondsLeft = GameConfig.magnetPickupDurationSec.toInt();
        _magnetTotalSeconds = magnetSecondsLeft;
        _magnetSecAccumulator = 0.0;
        magnetUsedThisRun = true;
        magnetsPicked += 1;
        magnetVN.value = 1.0;
        _achievementService.updateProgress(AchievementType.useMagnet, 1);
      }
    }

    // Speed boost pickup
    for (final speedBoost in children.whereType<SpeedBoostPowerUp>().toList()) {
      if (_overlap(player, speedBoost)) {
        speedBoost.removeFromParent();
        speedBoostSecondsLeft = GameConfig.speedBoostPickupDurationSec;
        playerSpeedMultiplier = max(
          playerSpeedMultiplier,
          GameConfig.speedBoostPowerUpMultiplier,
        );
      }
    }

    // Shield pickup
    for (final shield in children.whereType<ShieldPowerUp>().toList()) {
      if (_overlap(player, shield)) {
        shield.removeFromParent();
        shieldSecondsLeft = GameConfig.shieldPickupDurationSec;
      }
    }

    // Obstacle collision
    for (final obs in children.whereType<Obstacle>().toList()) {
      if (_overlap(player, obs)) {
        // Jika shield aktif, gunakan shield dan hapus obstacle
        if (shieldSecondsLeft > 0) {
          shieldSecondsLeft = 0;
          obs.removeFromParent();
          add(
            FlashOverlay(size: size, color: const Color(0x553498DB)),
          ); // Blue flash untuk shield
        } else {
          add(FlashOverlay(size: size));
          gameOver();
          break;
        }
      }
    }

    // End session when time runs out
    if (remaining <= 0) {
      gameOver();
    }
  }

  /// Ends the session, switches to GameOver overlay, and updates
  /// score-based achievements. Idempotent when already not playing.
  void gameOver() {
    if (!isPlaying) return;
    isPlaying = false;
    baseScoreAtGameOver = scoreVN.value;
    bestScore =
        baseScoreAtGameOver > bestScore ? baseScoreAtGameOver : bestScore;

    _safeRemoveOverlay(overlayHud);
    _safeAddOverlay(overlayGameOver);

    // Score-based achievements
    final lastScore = baseScoreAtGameOver;
    _achievementService.updateProgress(AchievementType.score100, lastScore);
    _achievementService.updateProgress(AchievementType.score500, lastScore);
    _achievementService.updateProgress(AchievementType.score1000, lastScore);
  }

  /// Revives from Game Over once per session, re-enables HUD and
  /// resumes play. Increments revive achievements.
  void revive() {
    if (isPlaying) return; // only revive from game over
    if (!reviveAvailable) return;
    reviveAvailable = false;
    reviveCount += 1;

    isPlaying = true;
    overlays.remove(overlayGameOver);
    _safeAddOverlay(overlayHud);

    _achievementService.updateProgress(AchievementType.reviveOnce, 1);
  }

  // Simple coin pickup API for achievements
  void onCoinPicked() {
    coinsPicked += 1;
    scoreVN.value += 1;
    _achievementService.updateProgress(
      AchievementType.collect10Coins,
      coinsPicked,
    );
    _achievementService.updateProgress(
      AchievementType.collect50Coins,
      coinsPicked,
    );
    _achievementService.updateProgress(
      AchievementType.collect100Coins,
      coinsPicked,
    );
  }

  int get lastScore => baseScoreAtGameOver;

  Future<void> applyDoubleCoinsReward() async {
    doubleCoinsUsed = true;
  }

  void markRewardDeposited() {
    rewardDeposited = true;
  }

  bool get doubleCoinsAvailable => !doubleCoinsUsed && !rewardDeposited;

  // === Helpers & Spawns ===
  bool _overlap(Component a, Component b) {
    if (a is RectangleComponent && b is RectangleComponent) {
      final ax = a.position.x - a.size.x / 2;
      final ay = a.position.y - a.size.y / 2;
      final bx = b.position.x - b.size.x / 2;
      final by = b.position.y - b.size.y / 2;
      return ax < bx + b.size.x &&
          ax + a.size.x > bx &&
          ay < by + b.size.y &&
          ay + a.size.y > by;
    }
    return false;
  }

  Vector2 _randomPos({double margin = 24}) {
    final x = margin + _rng.nextDouble() * (size.x - 2 * margin);
    final y = margin + _rng.nextDouble() * (size.y - 2 * margin);
    return Vector2(x, y);
  }

  void _spawnCoin() {
    if (!isPlaying) return;
    add(Coin(position: _randomPos()));
  }

  void _spawnMagnet() {
    if (!isPlaying) return;
    add(MagnetPowerUp(position: _randomPos()));
  }

  void _spawnSpeedBoost() {
    if (!isPlaying) return;
    add(SpeedBoostPowerUp(position: _randomPos()));
  }

  void _spawnShield() {
    if (!isPlaying) return;
    add(ShieldPowerUp(position: _randomPos()));
  }

  void _spawnObstacle() {
    if (!isPlaying) return;
    final pos = _randomPos();
    final speedX =
        GameConfig.obstacleMinSpeed +
        _rng.nextDouble() * GameConfig.obstacleMaxSpeedBonus;
    final speedY =
        GameConfig.obstacleMinSpeed +
        _rng.nextDouble() * GameConfig.obstacleMaxSpeedBonus;
    final vx = _rng.nextBool() ? speedX : -speedX;
    final vy = _rng.nextBool() ? speedY : -speedY;
    add(Obstacle(position: pos, velocity: Vector2(vx, vy)));
  }

  /// Adds overlay safely, ignoring missing builder asserts in tests.
  void _safeAddOverlay(String name) {
    try {
      overlays.add(name);
    } catch (_) {
      // ignore in tests without overlay builders
    }
  }

  /// Removes overlay safely, ignoring missing builder asserts in tests.
  void _safeRemoveOverlay(String name) {
    try {
      overlays.remove(name);
    } catch (_) {
      // ignore
    }
  }
}
