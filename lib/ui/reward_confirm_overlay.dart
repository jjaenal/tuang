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
    final reward = game.lastScore;
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
            child: MenuPanel(
              title: 'Double Reward',
              dark: true,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Double Coins diterapkan!\nReward: +$reward coins',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                NeumorphicButton(
                  label: 'Lanjut main',
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
                        fields: {'amount': game.lastScore, 'action': 'restart_from_double'},
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reward: +${game.lastScore} coins')),
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
                        fields: {'amount': game.lastScore, 'action': 'back_to_menu_from_double'},
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Reward: +${game.lastScore} coins')),
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
      ],
    );
  }
}