import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/game/my_game.dart';

void main() {
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