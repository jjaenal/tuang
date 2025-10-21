import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import 'components/menu_components.dart';
import 'options_panel.dart';

class PauseOverlay extends StatelessWidget {
  final MyGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop semi-transparan
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Center(
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, settings) {
              return MenuPanel(
                title: 'Paused',
                onClose: () => context.read<AppSettingsCubit>().setPaused(false),
                children: [
                  const SizedBox(height: 8),
                  MenuButton(
                    label: settings.paused ? 'Resume' : 'Resume',
                    icon: Icons.play_arrow,
                    onPressed: () {
                      context.read<AppSettingsCubit>().setPaused(false);
                    },
                  ),
                  const SizedBox(height: 8),
                  MenuButton(
                    label: 'Restart',
                    icon: Icons.restart_alt,
                    onPressed: () {
                      final cubit = context.read<AppSettingsCubit>();
                      if (settings.paused) {
                        cubit.setPaused(false);
                      }
                      game.startGame();
                    },
                  ),
                  const SizedBox(height: 12),
                  OptionRow(
                    icon: Icons.volume_up,
                    label: 'Audio',
                    trailing: Switch(
                      value: settings.audioOn,
                      onChanged: (_) => context.read<AppSettingsCubit>().toggleAudio(),
                    ),
                  ),
                  OptionRow(
                    icon: Icons.vibration,
                    label: 'Haptics',
                    trailing: Switch(
                      value: settings.hapticsOn,
                      onChanged: (_) => context.read<AppSettingsCubit>().toggleHaptics(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Opsional: tombol ke Options Panel
                  MenuButton(
                    label: 'Options…',
                    icon: Icons.settings,
                    onPressed: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black54,
                        builder: (ctx) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: const EdgeInsets.all(16),
                          child: OptionsPanel(),
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}