import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioService I = AudioService._();
  AudioService._();

  // Mode testing: ketika true, melewati inisialisasi/akses plugin audio agar unit test stabil
  static bool testMode = false;
  bool _muted = false;
  bool get muted => _muted;

  // Untuk pengujian: menyimpan nama aset sfx terakhir yang diminta diputar
  String? lastSfxPlayed;

  // Inisialisasi channel BGM; di-mode test di-skip untuk menghindari pembuatan AudioPlayer
  Future<void> init() async {
    if (testMode) return;
    try {
      await FlameAudio.bgm.initialize();
    } catch (_) {}
  }

  // Menyetel status mute; ketika mute, coba hentikan BGM (kecuali saat testMode)
  void setMuted(bool muted) {
    _muted = muted;
    if (muted) {
      if (testMode) return;
      try {
        FlameAudio.bgm.stop();
      } catch (_) {}
    }
  }

  // Helper sfx: memicu pemutaran suara koin/magnet/hit
  void playCoin() => _play('coin.wav');
  void playMagnet() => _play('magnet.wav');
  void playHit() => _play('hit.wav');

  // Memutar sfx dengan aman: catat aset, hormati mute, dan hindari pemanggilan plugin saat test/web
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