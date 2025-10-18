import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'player.dart';
import 'coin.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'effects.dart';
import 'obstacle.dart';
import 'magnet.dart';
import '../services/audio_service.dart';

class MyGame extends FlameGame {
  static const String overlayMainMenu = 'MainMenu';
  static const String overlayHud = 'Hud';
  static const String overlayGameOver = 'GameOver';

  Vector2 inputDir = Vector2.zero();

  late final Player player;
  final ValueNotifier<int> scoreVN = ValueNotifier<int>(0);
  final ValueNotifier<int> timeVN = ValueNotifier<int>(0);
  int lastScore = 0;
  int bestScore = 0;
  final Timer _coinTimer = Timer(1.5, repeat: true);
  final Timer _obstacleTimer = Timer(2.5, repeat: true);
  final Random _rng = Random();
  double _elapsed = 0;
  double sessionLength = 30; // seconds
  bool isPlaying = false;
  // Revive satu kali per sesi: _revivedOnce melacak apakah sudah digunakan
  bool _revivedOnce = false;
  // reviveAvailable diekspos ke UI agar tombol Revive dapat dinonaktifkan
  bool get reviveAvailable => !_revivedOnce;

  // speed boost mechanics
  double playerSpeedMultiplier = 1.0;
  double _boostTimeLeft = 0.0;
  final double _boostDuration = 0.5; // seconds
  final double _boostAmount = 0.6;   // +60% speed

  // screen shake
  double _shakeTimeLeft = 0.0;
  double _shakeIntensity = 0.0;

  // Magnet power-up configuration & state:
  // - _magnetTimer schedules spawns periodically
  // - _magnetTimeLeft counts down active magnet duration
  // - _magnetDuration controls active time per pickup
  // - magnetRadius and magnetStrength define coin pull behavior
  final Timer _magnetTimer = Timer(8.0, repeat: true);
  double _magnetTimeLeft = 0.0;
  final double _magnetDuration = 6.0;
  final double magnetRadius = 120.0;
  final double magnetStrength = 220.0;

  // HUD notifiers:
  // - magnetVN: 0..1 progress for magnet duration (HUD bar)
  // - comboVN: current combo multiplier shown in HUD
  final ValueNotifier<double> magnetVN = ValueNotifier<double>(0.0);
  final ValueNotifier<int> comboVN = ValueNotifier<int>(1);

  // Combo multiplier state:
  // - _comboCount increments per coin within window
  // - _comboTimeLeft decays; resets combo when it reaches 0
  // - _comboWindow defines allowed gap between coin pickups
  // - _comboMultiplier computed as 1 + (_comboCount ~/ 3)
  int _comboCount = 0;
  double _comboTimeLeft = 0.0;
  final double _comboWindow = 1.4;
  int _comboMultiplier = 1;

  @override
  Color backgroundColor() => const Color(0xFF101418);

  @override
  Future<void> onLoad() async {
    await _loadBestScore();
    add(_KeyboardController(this));

    player = Player();
    add(player);

    _coinTimer.onTick = spawnCoin;
    _obstacleTimer.onTick = spawnObstacle;
    _magnetTimer.onTick = spawnMagnet;

    timeVN.value = sessionLength.toInt();
    overlays.add(overlayMainMenu);
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('bestScore') ?? 0;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('bestScore', bestScore);
  }

  void startGame() {
    scoreVN.value = 0;
    lastScore = 0;
    _elapsed = 0;
    isPlaying = true;

    playerSpeedMultiplier = 1.0;
    _boostTimeLeft = 0.0;

    _shakeTimeLeft = 0.0;
    _shakeIntensity = 0.0;

    _coinTimer.stop();
    _coinTimer.limit = 1.5;
    _coinTimer.start();

    _obstacleTimer.stop();
    _obstacleTimer.limit = 2.5;
    _obstacleTimer.start();

    _magnetTimer.stop();
    _magnetTimer.limit = 8.0;
    _magnetTimer.start();

    _magnetTimeLeft = 0.0;
    magnetVN.value = 0.0;

    _comboCount = 0;
    _comboTimeLeft = 0.0;
    _comboMultiplier = 1;
    comboVN.value = 1;

    timeVN.value = sessionLength.toInt();

    children.whereType<Coin>().forEach((c) => c.removeFromParent());
    children.whereType<Obstacle>().forEach((o) => o.removeFromParent());
    children.whereType<MagnetPowerUp>().forEach((m) => m.removeFromParent());

    _revivedOnce = false; // reset kesempatan revive saat memulai permainan baru

    _safeOverlayRemove(overlayMainMenu);
    _safeOverlayAdd(overlayHud);
  }

  void gameOver() {
    isPlaying = false;
    lastScore = scoreVN.value;
    if (lastScore > bestScore) {
      bestScore = lastScore;
      _saveBestScore();
    }
    _safeOverlayRemove(overlayHud);
    _safeOverlayAdd(overlayGameOver);
  }

  void revive() {
    if (isPlaying) return;
    if (_revivedOnce) return;
    _revivedOnce = true; // gunakan kesempatan revive dan tandai sudah digunakan
    isPlaying = true;
    _safeOverlayRemove(overlayGameOver);
    _safeOverlayAdd(overlayHud); // kembali ke HUD setelah revive
    try {
      _triggerShake(intensity: 8, duration: 0.18);
      add(FlashOverlay(size: size, color: Colors.greenAccent));
    } catch (_) {}
  }

  // Helper overlay aman: cegah AssertionError saat overlay builder tidak tersedia (mis. lingkungan test)
  void _safeOverlayAdd(String name) {
    try {
      overlays.add(name);
    } catch (_) {}
  }

  // Helper overlay aman: penghapusan overlay dengan try-catch
  void _safeOverlayRemove(String name) {
    try {
      overlays.remove(name);
    } catch (_) {}
  }

  void addScore(int delta) {
    scoreVN.value += delta;
  }

  void spawnCoin() {
    if (!isPlaying) return;
    final double margin = 16;
    final pos = Vector2(
      margin + _rng.nextDouble() * (size.x - margin * 2),
      margin + _rng.nextDouble() * (size.y - margin * 2),
    );
    add(Coin(position: pos));
  }

  void spawnObstacle() {
    if (!isPlaying) return;
    final double margin = 20;
    final pos = Vector2(
      margin + _rng.nextDouble() * (size.x - margin * 2),
      margin + _rng.nextDouble() * (size.y - margin * 2),
    );
    final angle = _rng.nextDouble() * pi * 2;
    final speed = 80 + _rng.nextDouble() * 140;
    final vel = Vector2(cos(angle), sin(angle)) * speed;
    add(Obstacle(position: pos, velocity: vel));
  }

  // Spawn a single MagnetPowerUp at a random position when timer ticks.
  // Enforces only one magnet existing at a time to avoid clutter.
  void spawnMagnet() {
    if (!isPlaying) return;
    if (children.whereType<MagnetPowerUp>().isNotEmpty) return;
    final double margin = 20;
    final pos = Vector2(
      margin + _rng.nextDouble() * (size.x - margin * 2),
      margin + _rng.nextDouble() * (size.y - margin * 2),
    );
    add(MagnetPowerUp(position: pos));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _elapsed += dt;
    _coinTimer.update(dt);
    _obstacleTimer.update(dt);
    _magnetTimer.update(dt);

    // apply camera shake
    if (_shakeTimeLeft > 0) {
      _shakeTimeLeft -= dt;
      final offset = Vector2(
        (_rng.nextDouble() * 2 - 1) * _shakeIntensity,
        (_rng.nextDouble() * 2 - 1) * _shakeIntensity,
      );
      camera.viewfinder.position = offset;
      if (_shakeTimeLeft <= 0) {
        camera.viewfinder.position = Vector2.zero();
      }
    }

    final remaining = (sessionLength - _elapsed).clamp(0, sessionLength);
    timeVN.value = remaining.ceil();

    // decay speed boost
    if (_boostTimeLeft > 0) {
      _boostTimeLeft -= dt;
      if (_boostTimeLeft <= 0) {
        playerSpeedMultiplier = 1.0;
      }
    }

    // Magnet countdown and HUD progress update.
    // magnetVN drives a 0..1 progress bar in HUD.
    if (_magnetTimeLeft > 0) {
      _magnetTimeLeft -= dt;
      magnetVN.value = (_magnetTimeLeft / _magnetDuration).clamp(0.0, 1.0);
      if (_magnetTimeLeft <= 0) {
        magnetVN.value = 0.0;
      }
    }

    // Combo decay and reset: when time window elapses, reset streak.
    if (_comboTimeLeft > 0) {
      _comboTimeLeft -= dt;
      if (_comboTimeLeft <= 0) {
        _comboCount = 0;
        _comboMultiplier = 1;
        comboVN.value = 1;
      }
    }

    // difficulty scaling: faster spawn over time
    final diff = (_elapsed / sessionLength).clamp(0.0, 1.0);
    final newLimit = 1.5 - diff * 1.0; // 1.5s -> 0.5s
    if ((_coinTimer.limit - newLimit).abs() > 0.01) {
      _coinTimer.limit = newLimit; // jangan reset timer setiap frame
    }
    final newObstacleLimit = 2.5 - diff * 1.2; // 2.5s -> ~1.3s
    if ((_obstacleTimer.limit - newObstacleLimit).abs() > 0.01) {
      _obstacleTimer.limit = newObstacleLimit;
    }

    // Magnet attraction: pull nearby coins towards the player while active.
    // Uses normalized vector scaled by magnetStrength for simple homing behavior.
    if (_magnetTimeLeft > 0) {
      for (final coin in children.whereType<Coin>()) {
        final toPlayer = player.position - coin.position;
        final dist = toPlayer.length;
        if (dist < magnetRadius && dist > 1) {
          toPlayer.normalize();
          coin.position += toPlayer * magnetStrength * dt;
        }
      }
    }

    // coin pickup & effects
    final playerTopLeft = player.position - player.size / 2;
    final playerBottomRight = playerTopLeft + player.size;
    for (final coin in children.whereType<Coin>()) {
      final coinTopLeft = coin.position - coin.size / 2;
      final coinBottomRight = coinTopLeft + coin.size;
      final intersects =
          playerTopLeft.x < coinBottomRight.x &&
          playerBottomRight.x > coinTopLeft.x &&
          playerTopLeft.y < coinBottomRight.y &&
          playerBottomRight.y > coinTopLeft.y;
      if (intersects) {
        // combo update
        _comboCount += 1;
        _comboTimeLeft = _comboWindow;
        _comboMultiplier = 1 + (_comboCount ~/ 3);
        comboVN.value = _comboMultiplier;

        addScore(_comboMultiplier);
        // apply speed boost
        playerSpeedMultiplier = 1.0 + _boostAmount;
        _boostTimeLeft = _boostDuration;

        // juicy effects
        _triggerShake(intensity: 6, duration: 0.12);
        add(FlashOverlay(size: size));
        add(PopEffect(position: coin.position.clone(), color: Colors.amber));
        add(FloatingText(position: coin.position.clone(), text: '+$_comboMultiplier', color: Colors.white));
        for (int i = 0; i < 12; i++) {
          final angle = _rng.nextDouble() * pi * 2;
          final speed = 80 + _rng.nextDouble() * 120;
          final vel = Vector2(cos(angle), sin(angle)) * speed;
          add(DotParticle(position: coin.position.clone(), velocity: vel, color: Colors.amber));
        }
        AudioService.I.playCoin();
        coin.removeFromParent();
      }
    }

    // Magnet pickup: activates magnet for _magnetDuration and triggers visual feedback.
    for (final m in children.whereType<MagnetPowerUp>()) {
      final mTopLeft = m.position - m.size / 2;
      final mBottomRight = mTopLeft + m.size;
      final pick =
          playerTopLeft.x < mBottomRight.x &&
          playerBottomRight.x > mTopLeft.x &&
          playerTopLeft.y < mBottomRight.y &&
          playerBottomRight.y > mTopLeft.y;
      if (pick) {
        _magnetTimeLeft = _magnetDuration;
        magnetVN.value = 1.0; // HUD progress resets to full
        add(FlashOverlay(size: size, color: Colors.greenAccent));
        add(PopEffect(position: m.position.clone(), color: Colors.greenAccent));
        AudioService.I.playMagnet();
        m.removeFromParent();
      }
    }

    // obstacle collision -> game over
    for (final obs in children.whereType<Obstacle>()) {
      final obsTopLeft = obs.position - obs.size / 2;
      final obsBottomRight = obsTopLeft + obs.size;
      final hit =
          playerTopLeft.x < obsBottomRight.x &&
          playerBottomRight.x > obsTopLeft.x &&
          playerTopLeft.y < obsBottomRight.y &&
          playerBottomRight.y > obsTopLeft.y;
      if (hit) {
        _triggerShake(intensity: 10, duration: 0.2);
        add(FlashOverlay(size: size, color: Colors.red));
        AudioService.I.playHit();
        gameOver();
        break;
      }
    }

    if (_elapsed >= sessionLength) {
      gameOver();
    }
  }

  // Triggers screen shake by setting intensity and duration; reset handled in update().
  void _triggerShake({double intensity = 6.0, double duration = 0.12}) {
    _shakeIntensity = intensity;
    _shakeTimeLeft = duration;
  }

  @override
  void onRemove() {
    scoreVN.dispose();
    timeVN.dispose();
    magnetVN.dispose();
    comboVN.dispose();
    super.onRemove();
  }
}

class _KeyboardController extends KeyboardListenerComponent {
  final MyGame game;
  _KeyboardController(this.game);

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final dir = Vector2.zero();
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) dir.x -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) dir.x += 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) dir.y -= 1;
    if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) dir.y += 1;
    game.inputDir = dir;
    return true; // handled
  }
}
