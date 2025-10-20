import 'package:flutter/foundation.dart';

/// LoggingService: util untuk mencatat event gameplay, UI, dan periklanan.
///
/// - `enabled`: mengaktifkan/menonaktifkan keluaran log.
/// - Durasi sesi: menyimpan waktu mulai saat `start_game` dan menghitung
///   `session_sec` saat `game_over`, kemudian mereset penanda sesi.
class LoggingService {
  static bool enabled = true; // bisa dimatikan jika perlu
  /// Timestamp awal sesi gameplay untuk perhitungan durasi saat game berakhir.
  static DateTime? _sessionStart;

  /// Mencatat sebuah `event` dengan field opsional.
  ///
  /// Parameters:
  /// - `event`: nama event (mis. `start_game`, `game_over`, `ad_interstitial_show`).
  /// - `fields`: pasangan key-value tambahan untuk konteks.
  ///
  /// Behavior:
  /// - Abaikan jika `enabled == false`.
  /// - Jika `event == start_game`, simpan waktu mulai.
  /// - Jika `event == game_over`, hitung `session_sec` dan reset waktu mulai.
  static void log(String event, {Map<String, Object?>? fields}) {
    if (!enabled) return;
    final buf = StringBuffer('[Log] $event');
    final f = fields;
    if (f != null && f.isNotEmpty) {
      for (final e in f.entries) {
        buf.write(' ${e.key}=${e.value}');
      }
    }
    final now = DateTime.now();
    // Instrumentasi sesi: tandai awal saat `start_game`
    if (event == 'start_game') {
      _sessionStart = now;
      // Instrumentasi sesi: hitung durasi saat `game_over`
    } else if (event == 'game_over' && _sessionStart != null) {
      final sec = now.difference(_sessionStart!).inSeconds;
      buf.write(' session_sec=$sec');
      _sessionStart = null;
    }
    debugPrint(buf.toString());
  }
}
