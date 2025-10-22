import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/logging_service.dart';
import '../services/achievement_service.dart';

class HudOverlay extends StatefulWidget {
  final dynamic game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late final AchievementService _achievementService;

  @override
  void initState() {
    super.initState();
    _achievementService = AchievementService.I;
    _achievementService.onAchievementUnlocked.addListener(
      _onAchievementUnlocked,
    );
  }

  void _onAchievementUnlocked() {
    final unlocked = _achievementService.onAchievementUnlocked.value;
    if (unlocked != null && mounted) {
      _achievementService.showNotification(context, unlocked);
      // clear notifier to avoid repeat
      _achievementService.onAchievementUnlocked.value = null;
    }
  }

  @override
  void dispose() {
    _achievementService.onAchievementUnlocked.removeListener(
      _onAchievementUnlocked,
    );
    super.dispose();
  }

  Widget _hudPill({
    required Widget child,
    Color? color,
    double radius = 10,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 6,
    ),
  }) {
    final baseColor = color ?? const Color(0x55000000);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: game.scoreVN,
                  builder:
                      (_, score, __) => _hudPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$score',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 6),
                // Saldo coins (persisten) dari AppSettingsCubit
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder:
                      (context, app) => _hudPill(
                        color: const Color(0x55330000),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.circle,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Coins: ${app.coins}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 6),
                // Magnet indicator: shows active state using progress bar (0..1)
                ValueListenableBuilder<double>(
                  valueListenable: game.magnetVN,
                  builder:
                      (_, mag, __) => _hudPill(
                        color: const Color(0x3300FF66),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bolt,
                              color: Colors.greenAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Magnet',
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 100,
                              height: 8,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: mag > 0 ? mag : 0.0,
                                  backgroundColor: const Color(0x22000000),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Colors.greenAccent,
                                      ),
                                  minHeight: 8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              mag > 0 ? '${game.magnetSecondsLeft}s' : 'Off',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 6),
                // Combo multiplier indicator: displays current combo streak multiplier.
                ValueListenableBuilder<int>(
                  valueListenable: game.comboVN,
                  builder:
                      (_, combo, __) => _hudPill(
                        color: const Color(0x3344AAFF),
                        child: Text(
                          'Combo x$combo',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                ),
                const SizedBox(height: 6),
                if (LoggingService.enabled)
                  _hudPill(
                    color: const Color(0x33112233),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bug_report,
                          color: Colors.lightBlueAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'C:${game.coinsPicked} M:${game.magnetsPicked} R:${game.reviveCount}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: game.timeVN,
                  builder:
                      (_, time, __) => _hudPill(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$time s',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
                const SizedBox(height: 6),
                // Controls: pause/resume & audio toggle (non-game state)
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder:
                      (context, app) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: app.paused ? 'Resume' : 'Pause',
                            icon: Icon(
                              app.paused ? Icons.play_arrow : Icons.pause,
                              color: Colors.white70,
                            ),
                            onPressed:
                                () => context
                                    .read<AppSettingsCubit>()
                                    .setPaused(!app.paused),
                          ),
                          IconButton(
                            tooltip: app.audioOn ? 'Mute' : 'Unmute',
                            icon: Icon(
                              app.audioOn ? Icons.volume_up : Icons.volume_off,
                              color: Colors.white70,
                            ),
                            onPressed:
                                () =>
                                    context
                                        .read<AppSettingsCubit>()
                                        .toggleAudio(),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
