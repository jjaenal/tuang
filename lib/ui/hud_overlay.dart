import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';

class HudOverlay extends StatelessWidget {
  final MyGame game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
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
                  builder: (_, score, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x55000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Score: $score', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 6),
                // Saldo coins (persisten) dari AppSettingsCubit
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, app) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x55330000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.amber, size: 14),
                        const SizedBox(width: 6),
                        Text('Coins: ${app.coins}', style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Magnet indicator: shows active state using progress bar (0..1)
                ValueListenableBuilder<double>(
                  valueListenable: game.magnetVN,
                  builder: (_, mag, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x3300FF66),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 6),
                        const Text('Magnet', style: TextStyle(color: Colors.white)),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 80,
                          height: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: mag > 0 ? mag : 0.0,
                              backgroundColor: const Color(0x22000000),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                              minHeight: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Combo multiplier indicator: displays current combo streak multiplier.
                ValueListenableBuilder<int>(
                  valueListenable: game.comboVN,
                  builder: (_, combo, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x3344AAFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Combo x$combo', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: game.timeVN,
                  builder: (_, time, __) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x55000000),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Time: ${time}s', style: const TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 6),
                // Controls: pause/resume & audio toggle (non-game state)
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, app) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: app.paused ? 'Resume' : 'Pause',
                        icon: Icon(app.paused ? Icons.play_arrow : Icons.pause, color: Colors.white70),
                        onPressed: () => context.read<AppSettingsCubit>().setPaused(!app.paused),
                      ),
                      IconButton(
                        tooltip: app.audioOn ? 'Mute' : 'Unmute',
                        icon: Icon(app.audioOn ? Icons.volume_up : Icons.volume_off, color: Colors.white70),
                        onPressed: () => context.read<AppSettingsCubit>().toggleAudio(),
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