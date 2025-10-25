import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import 'components/menu_components.dart';
import 'options_panel.dart';
import 'theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Overlay pause yang menampilkan kontrol audio/haptics dan opsi.
class PauseOverlay extends StatelessWidget {
  final MyGame game;
  const PauseOverlay({super.key, required this.game});

  /// Membangun panel menu pause dengan pengaturan dan akses OptionsPanel.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Stack(
      children: [
        // Backdrop semi-transparan
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        Center(
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, settings) {
              return MenuPanel(
                title: l10n.optionsTitle, // or l10n.pauseTitle if desired
                dark: true,
                onClose:
                    () => context.read<AppSettingsCubit>().setPaused(false),
                children: [
                  const SizedBox(height: 8),
                  OptionRow(
                    icon: Icons.volume_up,
                    label: l10n.audioLabel,
                    trailing: Switch(
                      value: settings.audioOn,
                      onChanged:
                          (_) => context.read<AppSettingsCubit>().toggleAudio(),
                    ),
                  ),
                  OptionRow(
                    icon: Icons.vibration,
                    label: l10n.hapticsLabel,
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
                    label: l10n.optionsButton,
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
