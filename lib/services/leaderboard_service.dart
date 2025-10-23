import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../state/pref_keys.dart';
import 'supabase_service.dart';

/// [LeaderboardService] manages score submissions and fetches top scores.
///
/// This simple leaderboard persists entries to `SharedPreferences` so scores
/// survive app restarts. It supports submitting scores and retrieving top-N
/// entries. Replace with a cloud backend (e.g., Firebase/Firestore) in production.
///
/// Example:
/// ```dart
/// final lb = LeaderboardService();
/// await lb.ensureLoaded();
/// lb.submitScore(playerId: 'alice', score: 1200);
/// final top10 = lb.topScores(limit: 10);
/// ```
class LeaderboardService {
  final List<_Entry> _entries = <_Entry>[];
  bool _loaded = false;

  String? _lastSubmittedPlayerId;
  int? _lastSubmittedTimestampMs;

  /// Ensure entries are loaded from SharedPreferences.
  /// Safe to call multiple times; subsequent calls are fast.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    try {
      await SupabaseService.I.ensureInit();
      final client = SupabaseService.I.client;
      if (client != null) {
        final data = await client
            .from('scores')
            .select('player_id, player_name, score, updated_at')
            .order('score', ascending: false)
            .limit(50);
        _entries
          ..clear()
          ..addAll(
            (data as List).map(
              (m) => _Entry(
                playerId:
                    (m['player_name'] as String?) ??
                    (m['player_id'] as String?) ??
                    '',
                score: (m['score'] as int?) ?? 0,
                timestampMs: _parseUpdatedAt(m['updated_at']),
              ),
            ),
          );
        _sort();
      } else {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString(PrefKeys.leaderboard);
        if (raw != null && raw.isNotEmpty) {
          final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
          _entries
            ..clear()
            ..addAll(
              list.map((e) {
                final m = e as Map<String, dynamic>;
                return _Entry(
                  playerId: m['id'] as String? ?? '',
                  score: m['score'] as int? ?? 0,
                  timestampMs:
                      m['ts'] as int? ?? DateTime.now().millisecondsSinceEpoch,
                );
              }),
            );
          _sort();
        }
      }
    } catch (_) {
      _entries.clear();
    }
    _enforceCap();
    _loaded = true;
  }

  /// Submits a [score] for a given [playerId].
  /// Returns `true` if the score was added or upgraded.
  /// Throws [ArgumentError] if inputs are invalid.
  void _enforceCap({int cap = 50}) {
    if (_entries.length > cap) {
      _entries.removeRange(cap, _entries.length);
    }
  }

  Future<bool> submitScoreAsync({
    required String playerId,
    required int score,
  }) async {
    if (playerId.isEmpty) {
      throw ArgumentError('playerId cannot be empty');
    }
    if (score < 0) {
      throw ArgumentError('score cannot be negative');
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    _lastSubmittedPlayerId = playerId;
    _lastSubmittedTimestampMs = now;

    final client = SupabaseService.I.client;
    if (client != null) {
      try {
        await client.from('scores').upsert({
          'player_id': playerId,
          'player_name': playerId,
          'score': score,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'player_id');
        debugPrint('Score submitted to Supabase: $playerId - $score');
      } catch (e) {
        debugPrint('Error submitting score to Supabase: $e');
      }
    }

    final idx = _entries.indexWhere((e) => e.playerId == playerId);
    if (idx >= 0) {
      final existing = _entries[idx];
      if (score > existing.score) {
        _entries[idx] = _Entry(
          playerId: playerId,
          score: score,
          timestampMs: now,
        );
        _sort();
        _enforceCap();
        _saveToPrefs();
        return true;
      }
      return false;
    }

    _entries.add(_Entry(playerId: playerId, score: score, timestampMs: now));
    _sort();
    _enforceCap();
    _saveToPrefs();
    return true;
  }

  /// Returns top-N scores, default [limit] is 10.
  /// If fewer entries exist, returns all.
  List<LeaderboardEntry> topScores({int limit = 10}) {
    if (limit <= 0) return const <LeaderboardEntry>[];
    final take =
        _entries
            .take(limit)
            .map(
              (e) => LeaderboardEntry(
                playerId: e.playerId,
                score: e.score,
                lastUpdatedMs: e.timestampMs,
              ),
            )
            .toList();
    return take;
  }

  /// Returns 1-based rank position of [playerId] or null if not found.
  int? rankOf(String playerId) {
    _sort();
    final idx = _entries.indexWhere((e) => e.playerId == playerId);
    if (idx == -1) return null;
    return idx + 1;
  }

  /// Exposes last submitted info in current session, if available.
  String? get lastSubmittedPlayerId => _lastSubmittedPlayerId;
  int? get lastSubmittedTimestampMs => _lastSubmittedTimestampMs;

  /// Clears all entries. Intended for tests.
  @visibleForTesting
  void clear() {
    _entries.clear();
    _saveToPrefs();
  }

  void _sort() {
    _entries.sort((a, b) {
      // Sort by score desc, then timestamp asc (earlier first for tie-breaker)
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      return a.timestampMs.compareTo(b.timestampMs);
    });
  }

  void _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data =
          _entries
              .map(
                (e) => {
                  'id': e.playerId,
                  'score': e.score,
                  'ts': e.timestampMs,
                },
              )
              .toList();
      await prefs.setString(PrefKeys.leaderboard, jsonEncode(data));
    } catch (_) {
      // Ignore persistence errors in production; could log if needed.
    }
  }
}

/// Public model for leaderboard entries.
class LeaderboardEntry {
  /// Unique player identifier or name.
  final String playerId;

  /// Player score.
  final int score;

  /// Last updated timestamp in milliseconds since epoch.
  final int lastUpdatedMs;

  const LeaderboardEntry({
    required this.playerId,
    required this.score,
    required this.lastUpdatedMs,
  });
}

/// Internal storage type.
class _Entry {
  final String playerId;
  final int score;
  final int timestampMs;
  _Entry({
    required this.playerId,
    required this.score,
    required this.timestampMs,
  });
}

int _parseUpdatedAt(dynamic value) {
  if (value is String) {
    return DateTime.tryParse(value)?.millisecondsSinceEpoch ??
        DateTime.now().millisecondsSinceEpoch;
  }
  if (value is int) return value;
  return DateTime.now().millisecondsSinceEpoch;
}
