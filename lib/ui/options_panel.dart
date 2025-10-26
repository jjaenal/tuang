import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/ad_service.dart';
import '../state/app_settings_cubit.dart';
import '../game/game_config.dart';
import 'components/menu_components.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';
import '../models/difficulty.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// OptionsPanel menampilkan pengaturan permainan (audio, haptics, iklan, bahasa,
/// tingkat kesulitan, buff harian, nama pemain, dan debug logging).
///
/// Widget ini menggunakan Bloc untuk membaca dan mengubah `AppSettingsCubit`,
/// serta memanfaatkan l10n (`AppLocalizations`) untuk semua label dan teks.
class OptionsPanel extends StatefulWidget {
  const OptionsPanel({super.key, this.asSheet = false, this.onClose});
  final bool asSheet;
  final VoidCallback? onClose;

  @override
  State<OptionsPanel> createState() => _OptionsPanelState();
}

class _OptionsPanelState extends State<OptionsPanel> {
  /// Menampilkan dialog consent (GDPR/CCPA) dan mengembalikan `true` jika user
  /// menyetujui. Dialog tidak bisa ditutup dengan tap di luar (barrierDismissible=false).
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

  /// Menentukan apakah region saat ini membutuhkan consent sebelum mengaktifkan iklan.
  bool _regionRequiresConsent() {
    return GameConfig.alwaysRequireConsent;
  }

  /// Memastikan consent tersedia sebelum mengaktifkan iklan:
  /// - Jika consent sudah diberikan, langsung toggle iklan
  /// - Jika region tidak membutuhkan consent, langsung toggle iklan
  /// - Jika membutuhkan, tampilkan dialog dan set consent jika disetujui
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

  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: Icon(icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, app) {
        final l10n = AppLocalizations.of(context);
        return Center(
          child: MenuPanel(
            title: l10n.optionsTitle,
            onClose: widget.onClose ?? () => Navigator.of(context).pop(),
            dark: true,
            asSheet: widget.asSheet,
            children: [
              _buildSection(
                icon: Icons.tune,
                title: '${l10n.audioLabel} & ${l10n.hapticsLabel}',
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
                  const SizedBox(height: 6),
                  OptionRow(
                    icon: Icons.vibration,
                    label: l10n.hapticsLabel,
                    trailing: Switch(
                      value: app.hapticsOn,
                      onChanged:
                          (_) =>
                              context.read<AppSettingsCubit>().toggleHaptics(),
                    ),
                  ),
                ],
              ),

              _buildSection(
                icon: Icons.ad_units,
                title: l10n.adsLabel,
                children: [
                  OptionRow(
                    icon: Icons.ad_units,
                    label: l10n.adsLabel,
                    trailing: Switch(
                      value: app.adsEnabled && app.consentGiven,
                      onChanged: (_) => _ensureConsentThenEnableAds(context),
                    ),
                  ),
                  const SizedBox(height: 6),
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
                          SnackBar(
                            content: Text(val ? l10n.npaOn : l10n.npaOff),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              _buildSection(
                icon: Icons.speed,
                title: l10n.difficultyLabel,
                children: [
                  OptionRow(
                    icon: Icons.speed,
                    label: l10n.difficultyLabel,
                    trailing: SizedBox(
                      width: 140,
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
                ],
              ),

              _buildSection(
                icon: Icons.person,
                title: l10n.playerSectionTitle,
                children: [
                  OptionRow(
                    icon: Icons.person,
                    label: l10n.playerNameLabel,
                    trailing: SizedBox(
                      width: 140,
                      child: TextField(
                        controller: TextEditingController(text: app.playerName),
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            context.read<AppSettingsCubit>().setPlayerName(
                              value,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.playerNameUpdated)),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  OptionRow(
                    icon: Icons.language,
                    label: l10n.languageLabel,
                    trailing: SizedBox(
                      width: 140,
                      child: DropdownButton<String>(
                        value: app.languageCode,
                        isExpanded: true,
                        isDense: true,
                        items: [
                          DropdownMenuItem(
                            value: 'id',
                            child: Text(
                              l10n.languageIndonesian,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'en',
                            child: Text(
                              l10n.languageEnglish,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        onChanged: (code) {
                          if (code != null) {
                            context.read<AppSettingsCubit>().setLanguageCode(
                              code,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
