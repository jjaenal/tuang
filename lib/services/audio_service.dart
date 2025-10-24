import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

/// AudioService mengelola BGM dan SFX untuk game.
///
/// Fitur:
/// - `init()`: inisialisasi BGM channel (skip saat `testMode`).
/// - `startBgm()`/`stopBgm()`: kontrol musik latar dengan guard untuk web/test.
/// - `setMuted()`: mematikan audio (auto stop BGM) atau mengaktifkan.
/// - `playCoin()`/`playMagnet()`/`playHit()`: helper SFX.
class AudioService {
  static final AudioService I = AudioService._();
  AudioService._();

  // Mode testing: ketika true, melewati inisialisasi/akses plugin audio agar unit test stabil
  static bool testMode = false;
  bool _muted = false;
  bool get muted => _muted;

  // Untuk pengujian: menyimpan nama aset sfx terakhir yang diminta diputar
  String? lastSfxPlayed;

  bool _bgmStarted = false;

  /// Inisialisasi channel BGM; di-mode test di-skip untuk menghindari pembuatan AudioPlayer
  Future<void> init() async {
    if (testMode) return;
    try {
      await FlameAudio.bgm.initialize();
    } catch (_) {}
  }

  /// Memulai musik latar; aman dipanggil berulang, di-skip pada web/testMode
  Future<void> startBgm({double volume = 0.6}) async {
    if (testMode) return;
    if (kIsWeb) return;
    if (_muted) return;
    // Hindari memanggil play berkali-kali tanpa henti
    if (_bgmStarted) return;
    try {
      // Nama file placeholder; tangani jika aset belum tersedia
      await FlameAudio.bgm.play('bgm.mp3', volume: volume);
      _bgmStarted = true;
    } catch (_) {
      // Abaikan error jika aset belum ada
    }
  }

  /// Hentikan musik latar
  void stopBgm() {
    if (testMode) return;
    if (kIsWeb) return;
    try {
      FlameAudio.bgm.stop();
    } catch (_) {}
    _bgmStarted = false;
  }

  /// Menyetel status mute; ketika mute, coba hentikan BGM (kecuali saat testMode)
  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      if (testMode) return;
      try {
        FlameAudio.bgm.stop();
      } catch (_) {}
      _bgmStarted = false;
    }
  }

  /// Helper sfx: memicu pemutaran suara koin/magnet/hit
  void playCoin() => _play('coin.wav');
  void playMagnet() => _play('magnet.wav');
  void playHit() => _play('hit.wav');

  /// Memutar sfx dengan aman: catat aset, hormati mute, dan hindari pemanggilan plugin saat test/web
  void _play(String asset) {
    lastSfxPlayed = asset;
    if (_muted) return;
    // Hindari crash di Web / bila asset belum tersedia / saat unit test.
    if (testMode) return;
    if (kIsWeb) return;
    try {
      FlameAudio.play(asset);
    } catch (_) {}
  }
}
