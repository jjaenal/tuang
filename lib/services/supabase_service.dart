import 'package:supabase_flutter/supabase_flutter.dart';

/// SupabaseService: inisialisasi klien Supabase dan health check sederhana.
///
/// - Membaca `SUPABASE_URL` dan `SUPABASE_ANON_KEY` via `dart-define`.
/// - Beroperasi dalam mode lokal jika tidak dikonfigurasi.
/// - Menyediakan `getHealth()` untuk memeriksa kemampuan read/write.
class SupabaseService {
  SupabaseClient? _client;
  bool _initAttempted = false;

  /// Singleton instance.
  static final SupabaseService I = SupabaseService._();
  SupabaseService._();

  /// Klien Supabase aktif (null jika belum terinisialisasi).
  SupabaseClient? get client => _client;
  /// Status apakah klien sudah terinisialisasi.
  bool get isInitialized => _client != null;

  /// Memastikan Supabase terinisialisasi sekali dengan konfigurasi yang tersedia.
  /// Jika `url` atau `anonKey` kosong, tetap dalam mode lokal (tanpa klien).
  Future<void> ensureInit() async {
    if (_initAttempted) return;
    _initAttempted = true;

    const String url = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
    const String anonKey = String.fromEnvironment(
      'SUPABASE_ANON_KEY',
      defaultValue: '',
    );

    if (url.isEmpty || anonKey.isEmpty) {
      // Not configured; stay in local mode.
      return;
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _client = Supabase.instance.client;
  }

  /// Mengembalikan status kesehatan koneksi Supabase: inisialisasi, read, dan write.
  /// Melakukan operasi read `select` dan write `upsert`/`delete` pada tabel `scores`.
  Future<SupabaseHealthStatus> getHealth() async {
    await ensureInit();
    if (_client == null) {
      return const SupabaseHealthStatus(
        initialized: false,
        canRead: false,
        canWrite: false,
      );
    }
    bool readOk = false;
    bool writeOk = false;
    try {
      await _client!.from('scores').select('player_id').limit(1);
      readOk = true;
    } catch (_) {}
    try {
      const testId = '__ping__';
      await _client!.from('scores').upsert({
        'player_id': testId,
        'player_name': testId,
        'score': 0,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'player_id');
      await _client!.from('scores').delete().eq('player_id', testId);
      writeOk = true;
    } catch (_) {}
    return SupabaseHealthStatus(
      initialized: true,
      canRead: readOk,
      canWrite: writeOk,
    );
  }
}

/// Status kesehatan Supabase untuk diagnosa sederhana.
class SupabaseHealthStatus {
  /// Apakah klien Supabase telah terinisialisasi.
  final bool initialized;
  /// Apakah operasi read berhasil.
  final bool canRead;
  /// Apakah operasi write berhasil.
  final bool canWrite;
  const SupabaseHealthStatus({
    required this.initialized,
    required this.canRead,
    required this.canWrite,
  });
}
