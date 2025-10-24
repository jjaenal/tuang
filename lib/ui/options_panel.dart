import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/ad_service.dart';
import '../services/logging_service.dart';
import '../state/app_settings_cubit.dart';
import '../game/game_config.dart';
import 'components/menu_components.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';
import '../models/difficulty.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OptionsPanel extends StatefulWidget {
  const OptionsPanel({super.key});

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  Future<bool> _showConsentDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierColor: AppTheme.barrierColorDark,
      builder:
          (ctx) => AlertDialog(
            title: Text(l10n.consentDialogTitle),
            content: Text(l10n.consentDialogContent2),
            actions: [
              NeumorphicButton(
                label: l10n.consentDisagree,
                onPressed: () => Navigator.of(ctx).pop(false),
                primary: false,
                size: ButtonSize.compact,
              ),
              NeumorphicButton(
                label: l10n.consentAgree,
                onPressed: () => Navigator.of(ctx).pop(true),
                primary: true,
                size: ButtonSize.compact,
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
        final l10n = AppLocalizations.of(context);
        return Center(
          child: MenuPanel(
            title: l10n.optionsTitle,
            onClose: () => Navigator.of(context).pop(),
            dark: true,
            children: [
              OptionRow(
                icon: Icons.volume_up,
                label: l10n.audioLabel,
                trailing: Switch(
                  value: app.audioOn,
                  onChanged:
                      (_) => context.read<AppSettingsCubit>().toggleAudio(),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.vibration,
                label: l10n.hapticsLabel,
                trailing: Switch(
                  value: app.hapticsOn,
                  onChanged:
                      (_) => context.read<AppSettingsCubit>().toggleHaptics(),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.ad_units,
                label: l10n.adsLabel,
                trailing: Switch(
                  value: app.adsEnabled && app.consentGiven,
                  onChanged: (_) => _ensureConsentThenEnableAds(context),
                ),
              ),
              const SizedBox(height: 8),
              OptionRow(
                icon: Icons.privacy_tip,
                label: l10n.npaLabel,
                trailing: Switch(
                  value: app.npaEnabled,
                  onChanged: (val) {
                    final cubit = context.read<AppSettingsCubit>();
                    cubit.toggleNpa();
                    AdService.I.setNonPersonalizedAds(val);
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      SnackBar(content: Text(val ? l10n.npaOn : l10n.npaOff)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Language selector
              OptionRow(
                icon: Icons.language,
                label: l10n.languageLabel,
                trailing: SizedBox(
                  width: 180,
                  child: DropdownButton<String>(
                    value: app.languageCode,
                    isExpanded: true,
                    items: [
                      DropdownMenuItem(
                        value: 'id',
                        child: Text(l10n.languageIndonesian),
                      ),
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(l10n.languageEnglish),
                      ),
                    ],
                    onChanged: (code) {
                      if (code != null) {
                        context.read<AppSettingsCubit>().setLanguageCode(code);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Difficulty selector
              OptionRow(
                icon: Icons.speed,
                label: l10n.difficultyLabel,
                trailing: SizedBox(
                  width: 180,
                  child: Slider(
                    value: app.difficulty.index.toDouble(),
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: app.difficulty.key.toUpperCase(),
                    onChanged: (val) {
                      final difficulty = Difficulty.values[val.round()];
                      context.read<AppSettingsCubit>().setDifficulty(
                        difficulty,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Daily Magnet slider pakai OptionRow dengan spacer
              OptionRow(
                icon: Icons.bolt,
                label: l10n.dailyMagnetLabel,
                trailing: SizedBox(
                  width: 180,
                  child: Slider(
                    value: app.dailyMagnetBuffSeconds.toDouble(),
                    min: 0,
                    max: GameConfig.maxDailyMagnetBuffSec.toDouble(),
                    divisions: GameConfig.maxDailyMagnetBuffSec,
                    label: '${app.dailyMagnetBuffSeconds}${l10n.secondsShort}',
                    onChanged: (val) {
                      context
                          .read<AppSettingsCubit>()
                          .setDailyMagnetBuffSeconds(val.round());
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Player Name input
              OptionRow(
                icon: Icons.person,
                label: l10n.playerNameLabel,
                trailing: SizedBox(
                  width: 180,
                  child: TextField(
                    controller: TextEditingController(text: app.playerName),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty) {
                        context.read<AppSettingsCubit>().setPlayerName(value);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.playerNameUpdated)),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Debug logging toggle
              OptionRow(
                icon: Icons.bug_report,
                label: l10n.debugLoggingLabel,
                trailing: Switch(
                  value: LoggingService.enabled,
                  onChanged: (val) {
                    LoggingService.enabled = val;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          val ? l10n.debugLoggingOn : l10n.debugLoggingOff,
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
