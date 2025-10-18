import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';

class MainMenuOverlay extends StatelessWidget {
  final MyGame game;
  const MainMenuOverlay({super.key, required this.game});

  Future<void> _ensureConsentThenEnableAds(BuildContext context) async {
    final cubit = context.read<AppSettingsCubit>();
    final state = cubit.state;
    if (state.consentGiven) {
      cubit.toggleAds();
      return;
    }
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Consent'),
        content: const Text('Apakah Anda setuju melihat iklan (GDPR/CCPA)?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Setuju')),
        ],
      ),
    );
    if (accepted == true) {
      cubit.setConsent(true);
      cubit.toggleAds();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xAA000000),
      child: Center(
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, app) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Endless Dodge & Collect',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Best: ${game.bestScore}', style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => game.startGame(),
                child: const Text('Play'),
              ),
              const SizedBox(height: 12),
              // Toggle audio
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.volume_up, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  const Text('Audio', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 8),
                  Switch(
                    value: app.audioOn,
                    onChanged: (_) => context.read<AppSettingsCubit>().toggleAudio(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Toggle ads (requires consent)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.ad_units, color: Colors.white70, size: 18),
                  const SizedBox(width: 6),
                  const Text('Ads', style: TextStyle(color: Colors.white70)),
                  const SizedBox(width: 8),
                  Switch(
                    value: app.adsEnabled && app.consentGiven,
                    onChanged: (val) => _ensureConsentThenEnableAds(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (app.adsEnabled && app.consentGiven)
                Container(
                  height: 50,
                  width: 320,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0x2233FF99),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Banner Ad (placeholder)', style: TextStyle(color: Colors.white70)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}