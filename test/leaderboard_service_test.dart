import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/services/leaderboard_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('LeaderboardService', () {
    test('submitScore adds entry and sorts by score desc', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      lb.submitScore(playerId: 'alice', score: 100);
      lb.submitScore(playerId: 'bob', score: 200);
      lb.submitScore(playerId: 'carol', score: 150);

      final top = lb.topScores(limit: 10);
      expect(top.length, 3);
      expect(top[0].playerId, 'bob');
      expect(top[0].score, 200);
      expect(top[1].playerId, 'carol');
      expect(top[2].playerId, 'alice');
    });

    test('topScores respects limit and tie-breaker by timestamp', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      lb.submitScore(playerId: 'a', score: 300);
      await Future.delayed(const Duration(milliseconds: 5));
      lb.submitScore(playerId: 'b', score: 300);
      final top1 = lb.topScores(limit: 1);
      expect(top1.length, 1);
      expect(top1[0].playerId, 'a');

      final top2 = lb.topScores(limit: 2);
      expect(top2.length, 2);
      expect(top2[0].playerId, 'a');
      expect(top2[1].playerId, 'b');
    });

    test('dedup per pemain mempertahankan skor tertinggi', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      lb.submitScore(playerId: 'alice', score: 100);
      // Skor lebih rendah tidak mengubah entri
      final changedLower = lb.submitScore(playerId: 'alice', score: 90);
      expect(changedLower, false);
      var top = lb.topScores(limit: 10);
      expect(top.length, 1);
      expect(top[0].playerId, 'alice');
      expect(top[0].score, 100);
      // Skor lebih tinggi melakukan upgrade
      final changedHigher = lb.submitScore(playerId: 'alice', score: 150);
      expect(changedHigher, true);
      top = lb.topScores(limit: 10);
      expect(top.length, 1);
      expect(top[0].playerId, 'alice');
      expect(top[0].score, 150);
    });

    test('cap penyimpanan ke 50 entri', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      for (int i = 0; i < 60; i++) {
        lb.submitScore(playerId: 'p$i', score: i);
      }
      final top = lb.topScores(limit: 100);
      // Hanya 50 entri terbaik yang disimpan
      expect(top.length, 50);
      // Skor tertinggi berada di depan
      expect(top[0].score, 59);
      // Entri terakhir adalah skor ke-10 (karena 60..10 disimpan)
      expect(top[49].score, 10);
    });

    test('clear empties entries', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      lb.submitScore(playerId: 'x', score: 10);
      expect(lb.topScores(limit: 10).length, 1);
      lb.clear();
      expect(lb.topScores(limit: 10).length, 0);
    });

    test('invalid input throws ArgumentError', () async {
      final lb = LeaderboardService();
      await lb.ensureLoaded();
      expect(
        () => lb.submitScore(playerId: '', score: 10),
        throwsArgumentError,
      );
      expect(
        () => lb.submitScore(playerId: 'ok', score: -1),
        throwsArgumentError,
      );
    });
  });
}
