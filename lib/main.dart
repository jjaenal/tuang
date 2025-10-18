import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'game/my_game.dart';
import 'ui/main_menu.dart';
import 'ui/game_over.dart';
import 'ui/hud_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final MyGame game = MyGame();
  runApp(MyApp(game: game));
}

class MyApp extends StatelessWidget {
  final MyGame game;
  const MyApp({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuang Game',
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: (details) {
            final delta = details.delta;
            final dir = Vector2(delta.dx, delta.dy);
            if (dir.length2 > 0) {
              dir.normalize();
              game.inputDir = dir;
            }
          },
          onPanEnd: (_) => game.inputDir = Vector2.zero(),
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            autofocus: true,
            onKey: (RawKeyEvent event) {
              final pressed = RawKeyboard.instance.keysPressed;
              final dir = Vector2.zero();
              if (pressed.contains(LogicalKeyboardKey.keyA) || pressed.contains(LogicalKeyboardKey.arrowLeft)) dir.x -= 1;
              if (pressed.contains(LogicalKeyboardKey.keyD) || pressed.contains(LogicalKeyboardKey.arrowRight)) dir.x += 1;
              if (pressed.contains(LogicalKeyboardKey.keyW) || pressed.contains(LogicalKeyboardKey.arrowUp)) dir.y -= 1;
              if (pressed.contains(LogicalKeyboardKey.keyS) || pressed.contains(LogicalKeyboardKey.arrowDown)) dir.y += 1;
              game.inputDir = dir;
            },
            child: GameWidget(
              game: game,
              overlayBuilderMap: {
                MyGame.overlayMainMenu: (context, g) => MainMenuOverlay(game: g as MyGame),
                MyGame.overlayHud: (context, g) => HudOverlay(game: g as MyGame),
                MyGame.overlayGameOver: (context, g) => GameOverOverlay(game: g as MyGame),
              },
            ),
          ),
        ),
      ),
    );
  }
}
