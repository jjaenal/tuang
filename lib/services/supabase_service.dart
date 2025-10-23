import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? _client;
  bool _initAttempted = false;

  static final SupabaseService I = SupabaseService._();
  SupabaseService._();

  SupabaseClient? get client => _client;
  bool get isInitialized => _client != null;

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

  Future<SupabaseHealthStatus> getHealth() async {
    await ensureInit();
    if (_client == null) {
      return const SupabaseHealthStatus(initialized: false, canRead: false, canWrite: false);
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
    return SupabaseHealthStatus(initialized: true, canRead: readOk, canWrite: writeOk);
  }
}

class SupabaseHealthStatus {
  final bool initialized;
  final bool canRead;
  final bool canWrite;
  const SupabaseHealthStatus({
    required this.initialized,
    required this.canRead,
    required this.canWrite,
  });
}
