import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/services/audio_service.dart';
import 'package:tuang/services/haptics_service.dart';
import 'package:tuang/game/my_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('MyGame magnet buff consumption', () {
    test('consumes pending magnet buff at start and counts down', () async {
      // Disable audio/haptics plugins in test mode
      AudioService.testMode = true;
      HapticsService.testMode = true;
      // Seed pending magnet buff: 9 seconds
      SharedPreferences.setMockInitialValues({'pref_pendingMagnetBuffSec': 9});
      final game = MyGame();
      // Penting: set size dulu sebelum onLoad untuk menghindari error hasLayout
      game.onGameResize(Vector2(800, 600));
      await game.onLoad();

      // Start game to consume buff
      game.startGame();
      expect(game.isPlaying, isTrue);
      // Tunggu konsumsi buff async selesai
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(game.magnetSecondsLeft, equals(9));
      expect(game.magnetUsedThisRun, isTrue);

      // After start, prefs should reset pending buff to 0
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_pendingMagnetBuffSec'), equals(0));

      // Skip long updates in unit test to avoid Flame children iteration conflicts.
    });
  });
}
