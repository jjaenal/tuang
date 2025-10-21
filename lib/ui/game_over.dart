import 'package:flutter/material.dart';
import '../game/my_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import 'package:flutter/foundation.dart';
import '../services/logging_service.dart';
import '../game/game_config.dart';
import '../services/leaderboard_service.dart';

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
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreVN,
              builder:
                  (_, score, __) => Text(
                    'Score: $score',
                    style: const TextStyle(color: Colors.white),
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Best: ${game.bestScore}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<int>(
              valueListenable: game.scoreVN,
              builder: (_, score, __) {
                final base = game.baseScoreAtGameOver;
                final doubledApplied = game.doubleCoinsUsed;
                final magnetUsed = game.magnetUsedThisRun;
                final deposited = game.rewardDeposited;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0x33000000),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rincian Reward',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Durasi sesi
                      Text(
                        'Durasi sesi: ${game.elapsed.toStringAsFixed(1)}s',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Coins dasar: $base',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Double Coins: ${doubledApplied ? 'Diterapkan' : 'Tersedia'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Magnet dipakai: ${magnetUsed ? 'Ya' : 'Tidak'}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Magnet diambil: ${game.magnetsPicked}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        'Koin diambil: ${game.coinsPicked}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total: +$score coins',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (!deposited)
                        const Text(
                          'Reward akan ditambahkan saat Restart atau Back to Menu',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final cubit = context.read<AppSettingsCubit>();
                if (!game.rewardDeposited) {
                  cubit.addCoins(game.lastScore);
                  game.markRewardDeposited();

                  // Submit score ke leaderboard
                  final leaderboard = LeaderboardService();
                  leaderboard.submitScore(
                    playerId: cubit.state.playerName,
                    score: game.lastScore,
                  );

                  LoggingService.log(
                    'reward_deposited',
                    fields: {'amount': game.lastScore, 'action': 'restart'},
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reward: +${game.lastScore} coins')),
                  );
                }
                LoggingService.log('restart');
                game.overlays.remove(MyGame.overlayGameOver);
                game.startGame();
              },
              child: const Text('Restart'),
            ),
            const SizedBox(height: 8),
            BlocBuilder<AppSettingsCubit, AppSettingsState>(
              builder: (context, settings) {
                final canRevive =
                    game.reviveAvailable &&
                    ((settings.consentGiven && settings.adsEnabled) ||
                        settings.coins >= 50);
                return ElevatedButton(
                  onPressed:
                      canRevive
                          ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final cubit = context.read<AppSettingsCubit>();
                            final adsAllowed =
                                settings.consentGiven && settings.adsEnabled;
                            bool revived = false;
                            LoggingService.log(
                              'revive_requested',
                              fields: {
                                'ads_allowed': adsAllowed,
                                'coins': settings.coins,
                              },
                            );
                            if (adsAllowed && !kIsWeb) {
                              final ok = await AdService.I.showRewardedRevive();
                              if (!context.mounted) return;
                              if (ok) {
                                LoggingService.log('revive_via_ad_ok');
                                game.revive();
                                revived = true;
                              } else {
                                LoggingService.log('revive_via_ad_fail');
                              }
                            }
                            if (!revived) {
                              final spent = cubit.spendCoins(
                                GameConfig.reviveCostCoins,
                              );
                              if (spent) {
                                LoggingService.log(
                                  'revive_via_coins_spent',
                                  fields: {'cost': GameConfig.reviveCostCoins},
                                );
                                game.revive();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Revive pakai ${GameConfig.reviveCostCoins} coins',
                                    ),
                                  ),
                                );
                              } else {
                                LoggingService.log('revive_insufficient_coins');
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Butuh ${GameConfig.reviveCostCoins} coins untuk revive',
                                    ),
                                  ),
                                );
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
                final canDouble =
                    game.doubleCoinsAvailable &&
                    ((settings.consentGiven && settings.adsEnabled) ||
                        settings.coins >= 50);
                return ElevatedButton(
                  onPressed:
                      canDouble
                          ? () async {
                            final messenger = ScaffoldMessenger.of(context);
                            final cubit = context.read<AppSettingsCubit>();
                            final adsAllowed =
                                settings.consentGiven && settings.adsEnabled;
                            bool doubled = false;
                            LoggingService.log(
                              'double_requested',
                              fields: {
                                'ads_allowed': adsAllowed,
                                'coins': settings.coins,
                                'base': game.lastScore,
                              },
                            );
                            if (adsAllowed && !kIsWeb) {
                              final ok = await AdService.I.showRewardedRevive();
                              if (!context.mounted) return;
                              if (ok) {
                                LoggingService.log('double_via_ad_ok');
                                await game.applyDoubleCoinsReward();
                                doubled = true;
                              } else {
                                LoggingService.log('double_via_ad_fail');
                              }
                            }
                            if (!doubled) {
                              final spent = cubit.spendCoins(
                                GameConfig.doubleCoinsCoins,
                              );
                              if (spent) {
                                LoggingService.log(
                                  'double_via_coins_spent',
                                  fields: {
                                    'cost': GameConfig.doubleCoinsCoins,
                                    'new': game.lastScore * 2,
                                  },
                                );
                                await game.applyDoubleCoinsReward();
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Double coins pakai ${GameConfig.doubleCoinsCoins} coins',
                                    ),
                                  ),
                                );
                              } else {
                                LoggingService.log('double_insufficient_coins');
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Butuh ${GameConfig.doubleCoinsCoins} coins untuk double coins',
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          : null,
                  child: Text(
                    'Double Coins (Iklan atau ${GameConfig.doubleCoinsCoins} coins)',
                  ),
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

                  // Submit score ke leaderboard
                  final leaderboard = LeaderboardService();
                  leaderboard.submitScore(
                    playerId: cubit.state.playerName,
                    score: game.lastScore,
                  );

                  LoggingService.log(
                    'reward_deposited',
                    fields: {
                      'amount': game.lastScore,
                      'action': 'back_to_menu',
                    },
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reward: +${game.lastScore} coins')),
                  );
                }
                LoggingService.log('back_to_menu');
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
