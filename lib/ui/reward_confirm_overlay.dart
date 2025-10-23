import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import '../services/logging_service.dart';
import '../services/leaderboard_service.dart';
import 'components/neumorphic_button.dart';
import 'components/menu_components.dart';
import 'components/bokeh_background.dart';
import 'theme/app_theme.dart';

class RewardConfirmOverlay extends StatelessWidget {
  final MyGame game;
  const RewardConfirmOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final base = game.baseScoreAtGameOver;
    final total = game.lastScore;
    return Stack(
      children: [
        const BokehBackground(
          backgroundColor: Colors.black,
          bokehCount: 10,
          intensity: 0.5,
        ),
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(
                  scale: 0.95 + 0.05 * t,
                  child: child,
                ),
              ),
              child: MenuPanel(
                title: 'Double Reward',
                dark: true,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Double Coins diterapkan!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Breakdown base + bonus = total
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.savings, color: Colors.amber, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Base: +$base',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.lightBlueAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Bonus Double: +$base',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Total: +$total coins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeumorphicButton(
                    label: 'Lanjut main',
                    primary: false,
                    onPressed: () async {
                      LoggingService.log('double_confirm_continue');
                      final cubit = context.read<AppSettingsCubit>();
                      if (!game.rewardDeposited) {
                        cubit.addCoins(total);
                        game.markRewardDeposited();
                        final leaderboard = LeaderboardService();
                        await leaderboard.submitScoreAsync(
                          playerId: cubit.state.playerName,
                          score: total,
                        );
                        LoggingService.log(
                          'reward_deposited',
                          fields: {'amount': total, 'action': 'restart_from_double'},
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reward: +$total coins')),
                          );
                        }
                      }
                      // Tutup overlay dan mulai game baru
                      game.overlays.remove(MyGame.overlayRewardConfirm);
                      game.overlays.remove(MyGame.overlayGameOver);
                      game.startGame();
                    },
                  ),
                  const SizedBox(height: 8),
                  NeumorphicButton(
                    label: 'Kembali ke Home',
                    icon: Icons.home,
                    primary: false,
                    onPressed: () async {
                      LoggingService.log('double_confirm_home');
                      final cubit = context.read<AppSettingsCubit>();
                      if (!game.rewardDeposited) {
                        cubit.addCoins(total);
                        game.markRewardDeposited();
                        final leaderboard = LeaderboardService();
                        await leaderboard.submitScoreAsync(
                          playerId: cubit.state.playerName,
                          score: total,
                        );
                        LoggingService.log(
                          'reward_deposited',
                          fields: {'amount': total, 'action': 'back_to_menu_from_double'},
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Reward: +$total coins')),
                          );
                        }
                      }
                      game.overlays.remove(MyGame.overlayRewardConfirm);
                      game.overlays.remove(MyGame.overlayGameOver);
                      game.overlays.add(MyGame.overlayMainMenu);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}