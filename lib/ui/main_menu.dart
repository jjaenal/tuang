import 'package:flutter/material.dart';
import '../game/my_game.dart';

class MainMenuOverlay extends StatelessWidget {
  final MyGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xAA000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Endless Dodge & Collect',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => game.startGame(),
              child: const Text('Play'),
            ),
            const SizedBox(height: 16),
            Container(
              height: 50,
              width: 320,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0x2233FF99),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Banner Ad (placeholder)', style: TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}