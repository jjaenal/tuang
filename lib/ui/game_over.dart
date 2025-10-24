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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../game/game_config.dart';
import 'package:provider/provider.dart';

/// GameOverOverlay: layar overlay ketika permainan berakhir.
/// Menampilkan skor akhir, opsi revive via rewarded ad, dan tombol restart/menu.
class GameOverOverlay extends StatelessWidget {
  final MyGame game;
  const GameOverOverlay({super.key, required this.game});

  /// Membangun UI layar Game Over.
  /// Berisi skor akhir, tombol revive (jika tersedia), dan aksi lanjut.
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
                  builder: (context, score, __) {
                    final base = game.baseScoreAtGameOver;
                    final doubledApplied = game.doubleCoinsUsed;
                    final magnetUsed = game.magnetUsedThisRun;
                    final deposited = game.rewardDeposited;
                    final l10n = AppLocalizations.of(context);
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
                          Text(
                            l10n.rewardDetailsTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Durasi sesi
                          Text(
                            l10n.sessionDurationSeconds(
                              game.elapsed.toStringAsFixed(1),
                            ),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.baseCoinsLabel(base),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          // Keep double coins status as-is (offstage)
                          Text(
                            'Double Coins: ${doubledApplied ? 'Diterapkan' : 'Tersedia'}',
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            magnetUsed
                                ? l10n.magnetUsedYesLabel
                                : l10n.magnetUsedNoLabel,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            l10n.magnetsPickedLabel(game.magnetsPicked),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          Text(
                            l10n.coinsPickedLabel(game.coinsPicked),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.totalCoinsLabel(score),
                            style: const TextStyle(color: Colors.white),
                          ),
                          if (!deposited)
                            Text(
                              l10n.rewardDepositHint,
                              style: const TextStyle(
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
                label: AppLocalizations.of(context).restartButton,
                primary: true,
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  final l10n = AppLocalizations.of(context);
                  final cubit = context.read<AppSettingsCubit>();
                  // Jika reward belum disetor, setorkan dulu ke wallet
                  if (!game.rewardDeposited) {
                    try {
                      // Gunakan Provider.of dengan listen: false untuk menghindari rebuild
                      final leaderboard = Provider.of<LeaderboardService>(context, listen: false);
                      await leaderboard.submitScoreAsync(
                        playerId: cubit.state.playerName,
                        score: game.lastScore,
                      );

                      LoggingService.log(
                        'reward_deposited',
                        fields: {'amount': game.lastScore, 'action': 'restart'},
                      );
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.rewardSnack(game.lastScore))),
                      );
                    } catch (e) {
                      LoggingService.log('leaderboard_error', fields: {'error': e.toString()});
                      // Lanjutkan restart meskipun ada error leaderboard
                    }
                  }
                  // Pastikan overlay lain non-aktif dan unpause sebelum start
                  game.overlays.remove(MyGame.overlayRewardConfirm);
                  game.overlays.remove(MyGame.overlayGameOver);
                  game.overlays.remove(MyGame.overlayMainMenu);
                  cubit.setPaused(false);
                  game.resumeEngine();
                  LoggingService.log('restart');
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
                      label: AppLocalizations.of(context).reviveButton,
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
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(context).reviveUnavailable,
                              ),
                            ),
                          );
                          return;
                        }
                        // Jika iklan tidak diizinkan/tersedia atau di web, beri info
                        if (!adsAllowed || kIsWeb) {
                          LoggingService.log('revive_unavailable_ads');
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                ).reviveAdsUnavailable,
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
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).reviveAdsUnavailable,
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
              // Tombol Double Reward (ditampilkan hanya jika tersedia dan belum disetor)
              if (game.doubleCoinsAvailable)
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, settings) {
                    final adsAllowed =
                        settings.consentGiven && settings.adsEnabled;
                    return NeumorphicButton(
                      label: AppLocalizations.of(context).doubleRewardTitle,
                      primary: true,
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        final cubit = context.read<AppSettingsCubit>();
                        LoggingService.log(
                          'double_requested',
                          fields: {'ads_allowed': adsAllowed},
                        );
                        // Jika iklan tidak diizinkan/tersedia atau di web, gunakan fallback koin
                        if (!adsAllowed || kIsWeb) {
                          final cost = GameConfig.doubleCoinsCoins;
                          final okSpend = cubit.spendCoins(cost);
                          if (!okSpend) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).notEnoughCoins,
                                ),
                              ),
                            );
                            return;
                          }
                          LoggingService.log('double_via_coins_ok',
                              fields: {'cost': cost});
                          game.applyDoubleCoinsReward();
                          game.overlays.remove(MyGame.overlayGameOver);
                          game.overlays.add(MyGame.overlayRewardConfirm);
                          return;
                        }
                        // Jalankan alur iklan (reuse rewarded revive slot untuk double)
                        final ok = await AdService.I.showRewardedRevive();
                        if (ok) {
                          LoggingService.log('double_via_ad_ok');
                          game.applyDoubleCoinsReward();
                          // Buka overlay konfirmasi total reward; tutup Game Over
                          game.overlays.remove(MyGame.overlayGameOver);
                          game.overlays.add(MyGame.overlayRewardConfirm);
                        } else {
                          // Fallback: coba bayar dengan koin jika iklan gagal
                          final cost = GameConfig.doubleCoinsCoins;
                          final okSpend = cubit.spendCoins(cost);
                          if (!okSpend) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  AppLocalizations.of(context).doubleCoinsAdsUnavailable,
                                ),
                              ),
                            );
                            return;
                          }
                          LoggingService.log('double_via_coins_ok',
                              fields: {'cost': cost});
                          game.applyDoubleCoinsReward();
                          game.overlays.remove(MyGame.overlayGameOver);
                          game.overlays.add(MyGame.overlayRewardConfirm);
                        }
                      },
                    );
                  },
                ),
              const SizedBox(height: 8),
              NeumorphicButton(
                label: AppLocalizations.of(context).backToMenuButton,
                primary: false,
                onPressed: () async {
                  final cubit = context.read<AppSettingsCubit>();
                  if (!game.rewardDeposited) {
                    cubit.addCoins(game.lastScore);
                    game.markRewardDeposited();

                    final leaderboard = LeaderboardService();
                    // Capture messenger before async await to avoid context after async gap
                    final messenger2 = ScaffoldMessenger.of(context);
                    final l10n = AppLocalizations.of(context);
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
                    messenger2.showSnackBar(
                      SnackBar(content: Text(l10n.rewardSnack(game.lastScore))),
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
