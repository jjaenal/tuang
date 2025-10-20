import 'package:flutter_test/flutter_test.dart';
import 'package:flame/components.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/game/my_game.dart';
import 'package:tuang/services/audio_service.dart';
import 'package:tuang/services/haptics_service.dart';

void main() {
  AudioService.testMode = true;
  HapticsService.testMode = true;
  group('MyGame session timing', () {
    test(
      'timeVN updates as elapsed increases and triggers gameOver at end',
      () async {
        SharedPreferences.setMockInitialValues({});
        final game = MyGame();
        await game.onLoad();
        game.onGameResize(Vector2(800, 600));
        game.startGame();
        expect(game.isPlaying, isTrue);

        // Small tick initializes countdown to session length
        game.update(0.1);
        expect(game.timeVN.value, equals(game.sessionLength.toInt()));

        // After ~1 second, countdown should decrease by 1
        game.update(1.0);
        expect(game.timeVN.value, equals((game.sessionLength - 1).ceil()));

        // Advance near to end
        game.update(28.0);
        expect(game.timeVN.value, equals(1));

        // Final tick should end session
        game.update(1.0);
        expect(game.isPlaying, isFalse);
      },
    );

    test('elapsed getter returns accumulated time', () async {
      SharedPreferences.setMockInitialValues({});
      final game = MyGame();
      await game.onLoad();
      game.onGameResize(Vector2(800, 600));
      game.startGame();
      game.update(3.5);
      expect(game.elapsed, closeTo(3.5, 1e-6));

      game.update(0.2);
      expect(game.elapsed, closeTo(3.7, 1e-6));
    });
  });
}
