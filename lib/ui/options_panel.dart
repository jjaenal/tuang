import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/ad_service.dart';
import '../services/logging_service.dart';
import '../state/app_settings_cubit.dart';
import '../game/game_config.dart';
import 'components/menu_components.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({super.key});

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  Future<bool> _showConsentDialog(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.barrierColorDark,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Consent Iklan'),
            content: const Text('Izinkan iklan dengan personalisasi?'),
            actions: [
              NeumorphicButton(
                label: 'Tidak',
                onPressed: () => Navigator.of(ctx).pop(false),
                primary: false,
                size: ButtonSize.compact,
                // width: 120,
                // height: 44,
              ),
              NeumorphicButton(
                label: 'Setuju',
                onPressed: () => Navigator.of(ctx).pop(true),
                primary: true,
                size: ButtonSize.compact,
                // width: 120,
                // height: 44,
              ),
            ],
          ),
    );
    return accepted == true;
  }

  bool _regionRequiresConsent() {
    return GameConfig.alwaysRequireConsent;
  }

  Future<void> _ensureConsentThenEnableAds(BuildContext context) async {
    final cubit = context.read<AppSettingsCubit>();
    final state = cubit.state;
    if (state.consentGiven) {
      cubit.toggleAds();
      return;
    }
    if (!_regionRequiresConsent()) {
      cubit.toggleAds();
      return;
    }
    final accepted = await _showConsentDialog(context);
    if (accepted) {
      cubit.setConsent(true);
      cubit.toggleAds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, app) {
        return Center(
          child: MenuPanel(
            title: 'Options',
            onClose: () => Navigator.of(context).pop(),
            dark: true,
            children: [
              OptionRow(
                icon: Icons.volume_up,
                label: 'Audio',
                trailing: Switch(
                  value: app.audioOn,
                  onChanged:
                      (_) => context.read<AppSettingsCubit>().toggleAudio(),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.vibration,
                label: 'Haptics',
                trailing: Switch(
                  value: app.hapticsOn,
                  onChanged:
                      (_) => context.read<AppSettingsCubit>().toggleHaptics(),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.ad_units,
                label: 'Ads',
                trailing: Switch(
                  value: app.adsEnabled && app.consentGiven,
                  onChanged: (_) => _ensureConsentThenEnableAds(context),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.privacy_tip,
                label: 'Non-Personalized Ads',
                trailing: Switch(
                  value: app.npaEnabled,
                  onChanged: (val) {
                    final cubit = context.read<AppSettingsCubit>();
                    cubit.toggleNpa();
                    AdService.I.setNonPersonalizedAds(val);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(val ? 'NPA ON' : 'NPA OFF')),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Daily Magnet slider pakai OptionRow dengan spacer
              OptionRow(
                icon: Icons.bolt,
                label: 'Daily Magnet',
                trailing: SizedBox(
                  width: 180,
                  child: Slider(
                    value: app.dailyMagnetBuffSeconds.toDouble(),
                    min: 0,
                    max: GameConfig.maxDailyMagnetBuffSec.toDouble(),
                    divisions: GameConfig.maxDailyMagnetBuffSec,
                    label: '${app.dailyMagnetBuffSeconds}s',
                    onChanged: (val) {
                      context
                          .read<AppSettingsCubit>()
                          .setDailyMagnetBuffSeconds(val.round());
                      // final seconds = val.round();
                      // final estimate = GameConfig.magnetBuffValueCoins(seconds);
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   SnackBar(
                      //     content: Text('Daily Magnet: ${seconds}s (~$estimate coins)'),
                      //   ),
                      // );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Debug logging toggle
              OptionRow(
                icon: Icons.bug_report,
                label: 'Debug Logging',
                trailing: Switch(
                  value: LoggingService.enabled,
                  onChanged: (val) {
                    LoggingService.enabled = val;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val ? 'Debug logging ON' : 'Debug logging OFF',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
