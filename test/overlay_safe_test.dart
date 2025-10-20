import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/game/my_game.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('startGame does not throw without overlay builders', () {
    final game = MyGame();
    expect(() => game.startGame(), returnsNormally);
  });

  test('gameOver does not throw without overlay builders', () {
    final game = MyGame();
    game.startGame();
    expect(() => game.gameOver(), returnsNormally);
  });

  test('revive does not throw and flips isPlaying', () {
    final game = MyGame();
    game.startGame();
    game.gameOver();
    expect(game.isPlaying, isFalse);
    expect(() => game.revive(), returnsNormally);
    expect(game.isPlaying, isTrue);
  });
}
