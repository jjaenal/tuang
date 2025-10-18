import 'package:flutter/material.dart';
import '../game/my_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';

class GameOverOverlay extends StatelessWidget {
  final MyGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xAA000000),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Game Over',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Score: ${game.lastScore}', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 4),
            Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove(MyGame.overlayGameOver);
                game.startGame();
              },
              child: const Text('Restart'),
            ),
            const SizedBox(height: 8),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, settings) {
                final canRevive = settings.consentGiven && settings.adsEnabled && game.reviveAvailable;
                return ElevatedButton(
                  onPressed: canRevive
                      ? () async {
                          final ok = await AdService.I.showRewardedRevive();
                          if (!context.mounted) return;
                          if (ok) {
                            game.revive();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Iklan belum tersedia')));
                          }
                        }
                      : null,
                  child: const Text('Revive (Tonton Iklan)'),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                game.overlays.remove(MyGame.overlayGameOver);
                game.overlays.add(MyGame.overlayMainMenu);
              },
              child: const Text('Back to Menu'),
            ),
          ],
        ),
      ),
    );
  }
}