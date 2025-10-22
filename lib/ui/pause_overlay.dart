import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import 'components/menu_components.dart';
import 'options_panel.dart';
import 'theme/app_theme.dart';

class PauseOverlay extends StatelessWidget {
  final MyGame game;
  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop semi-transparan
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        Center(
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, settings) {
              return MenuPanel(
                title: 'Paused',
                dark: true,
                onClose:
                    () => context.read<AppSettingsCubit>().setPaused(false),
                children: [
                  const SizedBox(height: 8),
                  OptionRow(
                    icon: Icons.volume_up,
                    label: 'Audio',
                    trailing: Switch(
                      value: settings.audioOn,
                      onChanged:
                          (_) => context.read<AppSettingsCubit>().toggleAudio(),
                    ),
                  ),
                  OptionRow(
                    icon: Icons.vibration,
                    label: 'Haptics',
                    trailing: Switch(
                      value: settings.hapticsOn,
                      onChanged:
                          (_) =>
                              context.read<AppSettingsCubit>().toggleHaptics(),
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
                        barrierColor: AppTheme.barrierColorDark,
                        builder:
                            (ctx) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: const EdgeInsets.all(16),
                              child: const OptionsPanel(),
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
