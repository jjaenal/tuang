import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// HapticsService: util sederhana untuk memberikan umpan balik getar/haptik.
/// Di-web akan diabaikan, dan memiliki guard agar aman di lingkungan test.
class HapticsService {
  static bool enabled = true;
  static bool testMode = false;

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

  static void coinPickup() {
    if (!_canUse()) return;
    try {
      HapticFeedback.selectionClick();
    } catch (_) {}
  }

  static void magnetPickup() {
    if (!_canUse()) return;
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}
  }

  static void revive() {
    if (!_canUse()) return;
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}
  }
}
