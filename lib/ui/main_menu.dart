import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../services/logging_service.dart';
import '../game/game_config.dart';

class MainMenuOverlay extends StatefulWidget {
  final MyGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  static const String _privacyUrl = 'https://example.com/privacy';
  BannerAd? _bannerAd;
  bool _bannerReady = false;
  Timer? _ticker;
  DateTime _now = DateTime.now();
  bool _debugLogging = true;
  bool _showGameSettings = false;

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _showConsentDialog(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Ads Consent'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Game ini menampilkan iklan untuk mendukung pengembangan.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Dengan menekan Setuju, Anda memberikan izin untuk menampilkan iklan.',
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Anda bisa mengubah pengaturan kapan saja di Main Menu.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Tidak Setuju'),
              ),
              TextButton(
                onPressed: () async {
                  final uri = Uri.parse(_privacyUrl);
                  try {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                child: const Text('Kebijakan Privasi'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Setuju'),
              ),
            ],
          ),
    );
    return accepted == true;
  }

  // Hook region gating: nanti bisa diganti dengan deteksi wilayah (EEA/UK/California)
  bool _regionRequiresConsent() {
    // Gunakan konfigurasi dari GameConfig untuk menentukan kebutuhan consent.
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
  void initState() {
    super.initState();
    _debugLogging = LoggingService.enabled;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _ticker?.cancel();
    super.dispose();
  }

  /// Muat banner ads dengan ukuran anchored adaptive agar pas di layar.
  /// Menggunakan lebar layar saat ini untuk menghitung tinggi adaptif.
  void _loadBannerIfNeeded(BuildContext ctx, AppSettingsState app) {
    if (_bannerAd != null) return;
    if (!app.adsEnabled || !app.consentGiven) return;
    if (kIsWeb) return; // hindari plugin di web

    // Hitung ukuran anchored adaptive berdasarkan lebar layar saat ini.
    final width = MediaQuery.of(ctx).size.width.truncate();
    AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(width).then((
      anchoredSize,
    ) {
      if (!mounted) return; // pastikan State masih hidup
      if (anchoredSize == null) return; // ukuran gagal dihitung, abaikan

      final ad = BannerAd(
        adUnitId: AdService.I.bannerUnitId(),
        size: anchoredSize,
        request: AdRequest(nonPersonalizedAds: app.npaEnabled),
        listener: BannerAdListener(
          onAdLoaded: (ad) => setState(() => _bannerReady = true),
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            setState(() {
              _bannerAd = null;
              _bannerReady = false;
            });
          },
        ),
      );
      ad.load();
      setState(() => _bannerAd = ad);
    });
  }

  String _formatHms(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(h)}:${two(m)}:${two(s)}';
  }

  /// Hitung countdown menuju klaim berikutnya (midnight lokal) saat sudah klaim hari ini.
  String? _nextClaimCountdown(AppSettingsCubit cubit) {
    if (cubit.canClaimDailyReward) return null;
    final now = _now.toLocal();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    ).add(const Duration(days: 1));
    final diff = nextMidnight.difference(now);
    if (diff.isNegative) return '00:00:00';
    return _formatHms(diff);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xAA000000),
      child: Center(
        child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
          builder: (context, app) {
            _loadBannerIfNeeded(
              context,
              app,
            ); // siapkan banner adaptive ketika syarat terpenuhi
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Endless Dodge & Collect',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Best: ${widget.game.bestScore}',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.circle, color: Colors.amber, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Coins: ${app.coins}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => widget.game.startGame(),
                  child: const Text('Play'),
                ),
                const SizedBox(height: 12),
                // Toggle audio
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.volume_up,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Audio',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: app.audioOn,
                      onChanged: (val) {
                        context.read<AppSettingsCubit>().toggleAudio();
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(val ? 'Audio ON' : 'Audio OFF'),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Toggle haptics
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.vibration,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Haptics',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: app.hapticsOn,
                      onChanged: (val) {
                        context.read<AppSettingsCubit>().toggleHaptics();
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(val ? 'Haptics ON' : 'Haptics OFF'),
                          ),
                        );
                      },
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
                const SizedBox(height: 8),
                // Toggle Non-Personalized Ads (NPA)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.privacy_tip,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Non-Personalized Ads',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Switch(
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
                  ],
                ),
                const SizedBox(height: 8),
                // Daily magnet buff tuning slider
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Daily Magnet',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
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
                          final messenger = ScaffoldMessenger.of(context);
                          final seconds = val.round();
                          final estimate = GameConfig.magnetBuffValueCoins(
                            seconds,
                          );
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Daily Magnet: ${seconds}s (~$estimate coins)',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '~${GameConfig.magnetBuffValueCoins(app.dailyMagnetBuffSeconds)} coins',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.settings, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    const Text(
                      'Game Settings',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _showGameSettings,
                      onChanged: (val) {
                        setState(() => _showGameSettings = val);
                      },
                    ),
                  ],
                ),
                if (_showGameSettings) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0x33000000),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Game Config',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildConfigItem(
                          'Daily Reward',
                          '${GameConfig.dailyRewardCoins} coins',
                        ),
                        _buildConfigItem(
                          'Revive Cost',
                          '${GameConfig.reviveCostCoins} coins',
                        ),
                        _buildConfigItem(
                          'Double Coins Cost',
                          '${GameConfig.doubleCoinsCoins} coins',
                        ),
                        _buildConfigItem(
                          'Session Length',
                          '${GameConfig.defaultSessionLengthSec}s',
                        ),
                        _buildConfigItem(
                          'Magnet Duration',
                          '${GameConfig.magnetPickupDurationSec}s',
                        ),
                        _buildConfigItem(
                          'Daily Magnet Buff',
                          '${GameConfig.defaultDailyMagnetBuffSec}s',
                        ),
                        _buildConfigItem(
                          'Max Revives',
                          '${GameConfig.maxRevivesPerSession}',
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bug_report,
                      color: Colors.white70,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Debug Logging',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: _debugLogging,
                      onChanged: (val) {
                        setState(() => _debugLogging = val);
                        LoggingService.enabled = val;
                        final messenger = ScaffoldMessenger.of(context);
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              val ? 'Debug logging ON' : 'Debug logging OFF',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),

                /// Tombol Daily Reward: aktif jika belum klaim hari ini.
                /// - Jika consent + ads aktif (non-web), tampilkan rewarded ad dan klaim bila sukses.
                /// - Jika tidak, klaim langsung dan beri umpan balik via SnackBar.
                Builder(
                  builder: (ctx) {
                    final cubit = ctx.read<AppSettingsCubit>();
                    final canClaim = cubit.canClaimDailyReward;
                    final countdown = _nextClaimCountdown(cubit);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x33220000),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.card_giftcard,
                                color: Colors.white70,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reward: +${GameConfig.dailyRewardCoins} coins + magnet ${app.dailyMagnetBuffSeconds}s (~${GameConfig.magnetBuffValueCoins(app.dailyMagnetBuffSeconds)} coins)',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton(
                          onPressed:
                              canClaim
                                  ? () async {
                                    const rewardCoins =
                                        GameConfig.dailyRewardCoins;
                                    LoggingService.log(
                                      'daily_reward_requested',
                                      fields: {
                                        'ads_enabled': app.adsEnabled,
                                        'consent': app.consentGiven,
                                      },
                                    );
                                    if (app.adsEnabled &&
                                        app.consentGiven &&
                                        !kIsWeb) {
                                      final ok =
                                          await AdService.I
                                              .showRewardedDailyReward();
                                      if (!ctx.mounted) return;
                                      if (ok) {
                                        cubit.markDailyRewardClaimedNow();
                                        cubit.addCoins(rewardCoins);
                                        cubit.grantMagnetBuff(
                                          app.dailyMagnetBuffSeconds,
                                        );
                                        LoggingService.log(
                                          'daily_reward_claimed',
                                          fields: {
                                            'coins': rewardCoins,
                                            'magnet_sec':
                                                app.dailyMagnetBuffSeconds,
                                            'via': 'ad',
                                          },
                                        );
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Daily reward: +${GameConfig.dailyRewardCoins} coins + magnet ${app.dailyMagnetBuffSeconds}s!',
                                            ),
                                          ),
                                        );
                                      } else {
                                        LoggingService.log(
                                          'daily_reward_ad_unavailable',
                                        );
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Iklan belum tersedia',
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      cubit.markDailyRewardClaimedNow();
                                      cubit.addCoins(rewardCoins);
                                      cubit.grantMagnetBuff(
                                        app.dailyMagnetBuffSeconds,
                                      );
                                      LoggingService.log(
                                        'daily_reward_claimed',
                                        fields: {
                                          'coins': rewardCoins,
                                          'magnet_sec':
                                              app.dailyMagnetBuffSeconds,
                                          'via': 'no_ad',
                                        },
                                      );
                                      if (!ctx.mounted) return;
                                      ScaffoldMessenger.of(ctx).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Daily reward: +${GameConfig.dailyRewardCoins} coins + magnet ${app.dailyMagnetBuffSeconds}s (tanpa iklan)',
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                  : null,
                          child: Text(
                            canClaim
                                ? 'Daily Reward'
                                : 'Daily Reward (next: ${countdown ?? "00:00:00"})',
                          ),
                        ),
                        if (!canClaim && countdown != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Next claim: $countdown',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),

                if (app.adsEnabled && app.consentGiven)
                  kIsWeb
                      ? Container(
                        height: 50,
                        width: 320,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x2233FF99),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Banner Ad (placeholder)',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : (_bannerAd != null && _bannerReady)
                      ? SizedBox(
                        height: _bannerAd!.size.height.toDouble(),
                        width: _bannerAd!.size.width.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      )
                      : Container(
                        height: 50,
                        width: 320,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x22FFFFFF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Memuat iklan...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
