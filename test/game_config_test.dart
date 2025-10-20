import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/game/game_config.dart';

void main() {
  group('GameConfig.magnetBuffValueCoins', () {
    test('returns 0 when seconds <= 0', () {
      expect(GameConfig.magnetBuffValueCoins(0), 0);
      expect(GameConfig.magnetBuffValueCoins(-5), 0);
    });

    test('calculates value per second', () {
      expect(
        GameConfig.magnetBuffValueCoins(1),
        GameConfig.magnetBuffValuePerSecondCoins,
      );
      expect(
        GameConfig.magnetBuffValueCoins(12),
        12 * GameConfig.magnetBuffValuePerSecondCoins,
      );
      expect(
        GameConfig.magnetBuffValueCoins(7),
        7 * GameConfig.magnetBuffValuePerSecondCoins,
      );
    });

    test('clamps to maxDailyMagnetBuffSec', () {
      final max = GameConfig.maxDailyMagnetBuffSec;
      expect(
        GameConfig.magnetBuffValueCoins(max + 100),
        max * GameConfig.magnetBuffValuePerSecondCoins,
      );
    });
  });
}
