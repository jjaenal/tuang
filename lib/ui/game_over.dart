import 'package:flutter/material.dart';
import '../game/my_game.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import 'package:flutter/foundation.dart';
import '../services/logging_service.dart';
import '../services/leaderboard_service.dart';
import 'components/neumorphic_button.dart';
import 'components/menu_components.dart';
import 'components/bokeh_background.dart';
import 'theme/app_theme.dart';

class GameOverOverlay extends StatelessWidget {
  final MyGame game;
  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background dengan efek bokeh halus
        const BokehBackground(
          backgroundColor: Colors.black,
          bokehCount: 12,
          intensity: 0.6,
        ),
        // Barrier gelap untuk kontras
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        Center(
          child: MenuPanel(
            title: 'Game Over',
            dark: true,
            children: [
              // Skor akhir menonjol
              ValueListenableBuilder<int>(
                valueListenable: game.scoreVN,
                builder: (_, score, __) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withValues(alpha: 0.2),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Score',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          shaderCallback:
                              (Rect rect) => const LinearGradient(
                                colors: [Colors.amber, Colors.orangeAccent],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ).createShader(
                                Rect.fromLTWH(0, 0, rect.width, rect.height),
                              ),
                          child: Text(
                            '$score',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Best: ${game.bestScore}',
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Offstage(
                offstage: true,
                child: ValueListenableBuilder<int>(
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
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              NeumorphicButton(
                label: 'Restart',
                primary: false,
                onPressed: () async {
                  final cubit = context.read<AppSettingsCubit>();
                  if (!game.rewardDeposited) {
                    cubit.addCoins(game.lastScore);
                    game.markRewardDeposited();

                    // Submit score ke leaderboard
                    final leaderboard = LeaderboardService();
                    await leaderboard.submitScoreAsync(
                      playerId: cubit.state.playerName,
                      score: game.lastScore,
                    );

                    LoggingService.log(
                      'reward_deposited',
                      fields: {'amount': game.lastScore, 'action': 'restart'},
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reward: +${game.lastScore} coins'),
                      ),
                    );
                  }
                  LoggingService.log('restart');
                  game.overlays.remove(MyGame.overlayGameOver);
                  game.startGame();
                },
              ),
              const SizedBox(height: 8),
              // Tombol Revive: sembunyikan hanya saat game over karena timeout
              if (game.lastGameOverCause != GameOverCause.timeout)
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, settings) {
                    final adsAllowed =
                        settings.consentGiven && settings.adsEnabled;
                    return NeumorphicButton(
                      label: 'Revive',
                      primary: false,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        LoggingService.log(
                          'revive_requested',
                          fields: {'ads_allowed': adsAllowed},
                        );
                        // Jika revive tidak tersedia (habis dipakai), beri info
                        if (!game.reviveAvailable) {
                          LoggingService.log('revive_unavailable_no_charge');
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('Revive tidak tersedia.'),
                            ),
                          );
                          return;
                        }
                        // Jika iklan tidak diizinkan/tersedia atau di web, beri info
                        if (!adsAllowed || kIsWeb) {
                          LoggingService.log('revive_unavailable_ads');
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Revive hanya via iklan. Iklan tidak tersedia.',
                              ),
                            ),
                          );
                          return;
                        }
                        // Jalankan alur iklan
                        final ok = await AdService.I.showRewardedRevive();
                        if (ok) {
                          LoggingService.log('revive_via_ad_ok');
                          game.revive();
                        } else {
                          LoggingService.log('revive_via_ad_fail');
                          if (context.mounted) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Revive hanya via iklan. Iklan tidak tersedia.',
                                ),
                              ),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              const SizedBox(height: 8),
              // Tombol Double Rewards: selalu tampilkan tanpa kecuali
              BlocBuilder<AppSettingsCubit, AppSettingsState>(
                builder: (context, settings) {
                  final adsAllowed =
                      settings.consentGiven && settings.adsEnabled;
                  final canDouble =
                      game.doubleCoinsAvailable && adsAllowed && !kIsWeb;
                  return NeumorphicButton(
                    label: 'Double Coins',
                    primary: false,
                    onPressed:
                        canDouble
                            ? () async {
                              final messenger = ScaffoldMessenger.of(context);
                              LoggingService.log(
                                'double_requested',
                                fields: {
                                  'ads_allowed': adsAllowed,
                                  'base': game.lastScore,
                                },
                              );
                              final ok = await AdService.I.showRewardedRevive();
                              if (ok) {
                                LoggingService.log('double_via_ad_ok');
                                await game.applyDoubleCoinsReward();
                                // Tampilkan overlay konfirmasi reward dan tutup Game Over
                                game.overlays.remove(MyGame.overlayGameOver);
                                game.overlays.add(MyGame.overlayRewardConfirm);
                                LoggingService.log('double_overlay_shown');
                              } else {
                                LoggingService.log('double_via_ad_fail');
                                if (context.mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Double Coins hanya via iklan. Iklan tidak tersedia.',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            : () async {
                              // Tombol selalu tampil, tapi jika tidak bisa double (ads tidak tersedia), tampilkan pesan
                              final messenger = ScaffoldMessenger.of(context);
                              LoggingService.log('double_unavailable');
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Double Coins hanya via iklan. Iklan tidak tersedia.',
                                  ),
                                ),
                              );
                            },
                  );
                },
              ),
              const SizedBox(height: 8),
              NeumorphicButton(
                label: 'Back to Menu',
                primary: false,
                onPressed: () async {
                  final cubit = context.read<AppSettingsCubit>();
                  if (!game.rewardDeposited) {
                    cubit.addCoins(game.lastScore);
                    game.markRewardDeposited();

                    final leaderboard = LeaderboardService();
                    await leaderboard.submitScoreAsync(
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
                      SnackBar(
                        content: Text('Reward: +${game.lastScore} coins'),
                      ),
                    );
                  }
                  LoggingService.log('back_to_menu');
                  game.overlays.remove(MyGame.overlayGameOver);
                  game.overlays.add(MyGame.overlayMainMenu);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
