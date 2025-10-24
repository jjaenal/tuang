import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// HapticsService: util sederhana untuk memberikan umpan balik getar/haptik.
/// Di-web akan diabaikan, dan memiliki guard agar aman di lingkungan test.
class HapticsService {
  static bool enabled = true;
  static bool testMode = false;

  /// Memeriksa apakah haptics dapat digunakan pada platform/kondisi saat ini.
  /// Mengembalikan `false` jika dimatikan, `kIsWeb`, `testMode`, atau binding belum siap.
  static bool _canUse() {
    if (!enabled || testMode) return false;
    if (kIsWeb) return false;
    // Pastikan binding tersedia agar pemanggilan HapticFeedback tidak memicu error di unit tests
    try {
      // Akan throw jika belum ada ServicesBinding yang terinisialisasi
      ServicesBinding.instance;
    } catch (_) {
      return false;
    }
    return true;
  }

  /// Memberikan haptik ringan saat koin diambil.
  static void coinPickup() {
    if (!_canUse()) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  /// Memberikan haptik ringan saat magnet diambil.
  static void magnetPickup() {
    if (!_canUse()) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  /// Memberikan haptik berat saat pemain revive.
  static void revive() {
    if (!_canUse()) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
