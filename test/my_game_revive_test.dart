import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/game/my_game.dart';
import 'package:tuang/services/audio_service.dart';
import 'package:tuang/services/haptics_service.dart';

void main() {
  AudioService.testMode = true;
  HapticsService.testMode = true;
  test('revive only once per session', () async {
    final game = MyGame();
    // start and then game over
    game.startGame();
    expect(game.isPlaying, isTrue);
    expect(game.reviveAvailable, isTrue);

    game.gameOver();
    expect(game.isPlaying, isFalse);

    game.revive();
    expect(game.isPlaying, isTrue);
    expect(game.reviveAvailable, isFalse);

    game.gameOver();
    expect(game.isPlaying, isFalse);

    // second revive should not start
    game.revive();
    expect(game.isPlaying, isFalse);
  });
}
