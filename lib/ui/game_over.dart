import 'package:flutter/material.dart';
import '../game/my_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import 'package:flutter/foundation.dart';

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
            ValueListenableBuilder<int>(
              valueListenable: game.scoreVN,
              builder: (_, score, __) => Text('Score: $score', style: const TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 4),
            Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final cubit = context.read<AppSettingsCubit>();
                if (!game.rewardDeposited) {
                  cubit.addCoins(game.lastScore);
                  game.markRewardDeposited();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reward: +${game.lastScore} coins')),
                  );
                }
                game.overlays.remove(MyGame.overlayGameOver);
                game.startGame();
              },
              child: const Text('Restart'),
            ),
            const SizedBox(height: 8),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, settings) {
                final canRevive = game.reviveAvailable && ((settings.consentGiven && settings.adsEnabled) || settings.coins >= 50);
                return ElevatedButton(
                  onPressed: canRevive
                      ? () async {
                          final adsAllowed = settings.consentGiven && settings.adsEnabled;
                          bool revived = false;
                          if (adsAllowed && !kIsWeb) {
                            final ok = await AdService.I.showRewardedRevive();
                            if (!context.mounted) return;
                            if (ok) {
                              game.revive();
                              revived = true;
                            }
                          }
                          if (!revived) {
                            final cubit = context.read<AppSettingsCubit>();
                            final spent = cubit.spendCoins(50);
                            if (spent) {
                              game.revive();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Revive pakai 50 coins')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Butuh 50 coins untuk revive')));
                            }
                          }
                        }
                      : null,
                  child: const Text('Revive (Iklan atau 50 coins)'),
                );
              },
            ),
            const SizedBox(height: 8),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, settings) {
                final canDouble = game.doubleCoinsAvailable && ((settings.consentGiven && settings.adsEnabled) || settings.coins >= 50);
                return ElevatedButton(
                  onPressed: canDouble
                      ? () async {
                          final adsAllowed = settings.consentGiven && settings.adsEnabled;
                          bool doubled = false;
                          if (adsAllowed && !kIsWeb) {
                            final ok = await AdService.I.showRewardedRevive();
                            if (!context.mounted) return;
                            if (ok) {
                              await game.applyDoubleCoinsReward();
                              doubled = true;
                            }
                          }
                          if (!doubled) {
                            final cubit = context.read<AppSettingsCubit>();
                            final spent = cubit.spendCoins(50);
                            if (spent) {
                              await game.applyDoubleCoinsReward();
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Double coins pakai 50 coins')));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Butuh 50 coins untuk double coins')));
                            }
                          }
                        }
                      : null,
                  child: const Text('Double Coins (Iklan atau 50 coins)'),
                );
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                final cubit = context.read<AppSettingsCubit>();
                if (!game.rewardDeposited) {
                  cubit.addCoins(game.lastScore);
                  game.markRewardDeposited();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reward: +${game.lastScore} coins')),
                  );
                }
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