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
import '../services/ad_service.dart';

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
  // Double coins hanya sekali per sesi game over
  bool _doubleCoinsUsed = false;
  bool get doubleCoinsAvailable => !_doubleCoinsUsed;
  
  // Flag deposit reward agar hanya sekali per game over
  bool _rewardDeposited = false;
  bool get rewardDeposited => _rewardDeposited;
  void markRewardDeposited() { _rewardDeposited = true; }

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

  // HUD properties for magnet progress & combo multiplier
  final ValueNotifier<double> magnetVN = ValueNotifier<double>(0.0);
  final ValueNotifier<int> comboVN = ValueNotifier<int>(1);
  int _comboCount = 0;
  int _comboMultiplier = 1;
  double _comboTimeLeft = 0.0;
  final double _comboWindow = 2.0;

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

  void startGame() {
    isPlaying = true;
    _elapsed = 0;
    scoreVN.value = 0;
    _revivedOnce = false;
    _doubleCoinsUsed = false;
    playerSpeedMultiplier = 1.0;
    _boostTimeLeft = 0.0;
    _comboCount = 0;
    _comboMultiplier = 1;
    _comboTimeLeft = 0.0;
    magnetVN.value = 0.0;
    comboVN.value = 1;

    _coinTimer.start();
    _obstacleTimer.start();
    _magnetTimer.start();

    _safeOverlayRemove(overlayMainMenu);
    _safeOverlayAdd(overlayHud);

    // Konsumsi buff magnet harian jika ada. Tangani kegagalan SharedPreferences di lingkungan test.
    SharedPreferences.getInstance().then((prefs) {
      final sec = prefs.getInt('pref_pendingMagnetBuffSec') ?? 0;
      if (sec > 0) {
        _magnetTimeLeft = sec.toDouble();
        magnetVN.value = 1.0;
        prefs.setInt('pref_pendingMagnetBuffSec', 0);
        // Sedikit efek visual/audio agar terasa.
        try {
          add(FlashOverlay(size: size, color: Colors.greenAccent, duration: 0.15));
        } catch (_) {}
        try {
          AudioService.I.playMagnet();
        } catch (_) {}
      }
    }).catchError((_) {
      // Abaikan saat SharedPreferences tidak tersedia (mis. unit test VM tanpa binding)
    });
  }

  void gameOver() {
    isPlaying = false;
    lastScore = scoreVN.value;
    if (lastScore > bestScore) {
      bestScore = lastScore;
      _saveBestScore();
    }
    _rewardDeposited = false;
    _safeOverlayRemove(overlayHud);
    _safeOverlayAdd(overlayGameOver);
    // Tampilkan interstitial jika tersedia (respect init, consent, cooldown)
    try {
      AdService.I.showInterstitial();
    } catch (_) {}
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
      add(FlashOverlay(size: size, color: Colors.greenAccent, duration: 0.15));
    } catch (_) {}
  }

  void _safeOverlayAdd(String name) {
    try {
      if (!overlays.isActive(name)) {
        overlays.add(name);
      }
    } catch (_) {}
  }

  void _safeOverlayRemove(String name) {
    try {
      if (overlays.isActive(name)) {
        overlays.remove(name);
      }
    } catch (_) {}
  }

  Future<void> _loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    bestScore = prefs.getInt('best_score') ?? 0;
  }

  Future<void> _saveBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best_score', bestScore);
  }

  void spawnCoin() {
    final pos = Vector2(_rng.nextDouble() * size.x, _rng.nextDouble() * size.y);
    add(Coin(position: pos));
  }

  void spawnObstacle() {
    final pos = Vector2(_rng.nextDouble() * size.x, _rng.nextDouble() * size.y);
    final angle = _rng.nextDouble() * pi * 2;
    final speed = 80 + _rng.nextDouble() * 140;
    final vel = Vector2(cos(angle), sin(angle)) * speed;
    add(Obstacle(position: pos, velocity: vel));
  }

  void spawnMagnet() {
    final pos = Vector2(_rng.nextDouble() * size.x, _rng.nextDouble() * size.y);
    add(MagnetPowerUp(position: pos));
  }

  void addScore(int delta) {
    scoreVN.value += delta;
  }

  void updateTimers(double dt) {
    _coinTimer.update(dt);
    _obstacleTimer.update(dt);
    _magnetTimer.update(dt);
  }

  void _triggerShake({double intensity = 6.0, double duration = 0.12}) {
    _shakeIntensity = intensity;
    _shakeTimeLeft = duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;

    _elapsed += dt;
    updateTimers(dt);

    // shake update
    if (_shakeTimeLeft > 0) {
      _shakeTimeLeft -= dt;
      if (_shakeTimeLeft <= 0) {
        _shakeIntensity = 0.0;
        _shakeTimeLeft = 0.0;
      }
    }

    // decay speed boost
    if (_boostTimeLeft > 0) {
      _boostTimeLeft -= dt;
      if (_boostTimeLeft <= 0) {
        playerSpeedMultiplier = 1.0;
      }
    }

    // combo window countdown
    if (_comboTimeLeft > 0) {
      _comboTimeLeft -= dt;
      if (_comboTimeLeft <= 0) {
        _comboMultiplier = 1;
        comboVN.value = _comboMultiplier;
      }
    }

    // magnet countdown
    if (_magnetTimeLeft > 0) {
      _magnetTimeLeft -= dt;
      if (_magnetTimeLeft < 0) _magnetTimeLeft = 0;
      magnetVN.value = (_magnetTimeLeft / _magnetDuration).clamp(0, 1);
    }

    // Magnet attraction: pull nearby coins towards the player while active
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

    // Player movement
    final move = inputDir.normalized() * (80.0 * playerSpeedMultiplier) * dt;
    player.position += move;

    // Keep player within the screen bounds
    final playerTopLeft = player.position - player.size / 2;
    final playerBottomRight = playerTopLeft + player.size;
    if (playerTopLeft.x < 0) player.position.x = player.size.x / 2;
    if (playerBottomRight.x > size.x) player.position.x = size.x - player.size.x / 2;
    if (playerTopLeft.y < 0) player.position.y = player.size.y / 2;
    if (playerBottomRight.y > size.y) player.position.y = size.y - player.size.y / 2;

    // coin pickup
    for (final coin in children.whereType<Coin>()) {
      final coinTopLeft = coin.position - coin.size / 2;
      final coinBottomRight = coinTopLeft + coin.size;
      final pick =
          playerTopLeft.x < coinBottomRight.x &&
          playerBottomRight.x > coinTopLeft.x &&
          playerTopLeft.y < coinBottomRight.y &&
          playerBottomRight.y > coinTopLeft.y;
      if (pick) {
        addScore(1);
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


  @override
  void onRemove() {
    scoreVN.dispose();
    timeVN.dispose();
    magnetVN.dispose();
    comboVN.dispose();
    super.onRemove();
  }

  Future<void> applyDoubleCoinsReward() async {
    if (_doubleCoinsUsed) return;
    _doubleCoinsUsed = true;
    final doubled = lastScore * 2;
    lastScore = doubled;
    scoreVN.value = doubled;
    if (lastScore > bestScore) {
      bestScore = lastScore;
      await _saveBestScore();
    }
  }
}

// Keyboard controller for web/desktop
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
