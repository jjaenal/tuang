import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../services/logging_service.dart';
import '../models/character_skin.dart';
import '../game/game_config.dart';
import 'leaderboard_screen.dart';
import 'options_panel.dart';
import 'achievements_screen.dart';
import 'components/bokeh_background.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';

class _HeroButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HeroButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  State<_HeroButton> createState() => _HeroButtonState();
}

class _HeroButtonState extends State<_HeroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const baseSurface = Color(0xFF1A1F24);
    const shadowDark = Color(0xFF0D1013);
    const shadowLight = Color(0xFF2A3138);

    final idleShadows = const [
      BoxShadow(color: shadowDark, blurRadius: 24, offset: Offset(10, 10)),
      BoxShadow(color: shadowLight, blurRadius: 24, offset: Offset(-10, -10)),
    ];
    final pressedShadows = const [
      BoxShadow(color: shadowDark, blurRadius: 12, offset: Offset(4, 4)),
      BoxShadow(color: shadowLight, blurRadius: 12, offset: Offset(-4, -4)),
    ];

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        scale: _pressed ? 0.98 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          width: 200,
          height: 80,
          decoration: BoxDecoration(
            color: baseSurface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _pressed ? pressedShadows : idleShadows,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1BB6A6), Color(0xFF0E9487)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 30),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainMenuOverlay extends StatefulWidget {
  final MyGame game;
  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  static const String _privacyUrl = String.fromEnvironment(
    'PRIVACY_URL',
    defaultValue: 'https://example.com/privacy',
  );
  BannerAd? _bannerAd;
  bool _bannerReady = false;
  Timer? _ticker;
  DateTime _now = DateTime.now();

  bool _consentPrompted = false;

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

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
    // Auto prompt consent on first boot if required and not yet given
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<AppSettingsCubit>();
      if (_consentPrompted) return;
      if (_regionRequiresConsent() && !cubit.state.consentGiven) {
        _consentPrompted = true;
        final accepted = await _showConsentDialog(context);
        if (!mounted) return;
        if (accepted) {
          cubit.setConsent(true);
          if (!cubit.state.adsEnabled) {
            cubit.toggleAds();
          }
        }
      }
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

  /// Membangun widget preview untuk skin yang aktif
  Widget _buildActiveSkinPreview(BuildContext context, String skinId) {
    // Cari skin dari daftar default skins
    final skin = CharacterSkin.defaultSkins.firstWhere(
      (skin) => skin.id == skinId,
      orElse: () => CharacterSkin.defaultSkins.first,
    );

    // Tampilkan preview berdasarkan tipe skin (image atau color)
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: skin.imagePath == null ? skin.color : null,
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(4),
        image:
            skin.imagePath != null
                ? DecorationImage(
                  image: AssetImage('assets/images/${skin.imagePath}'),
                  fit: BoxFit.cover,
                )
                : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BokehBackground(
          backgroundColor: Colors.black,
          bokehCount: 12,
          intensity: 0.6,
        ),
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        Center(
          child: BlocBuilder<AppSettingsCubit, AppSettingsState>(
            builder: (context, app) {
              _loadBannerIfNeeded(
                context,
                app,
              ); // siapkan banner adaptive ketika syarat terpenuhi
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Game Title dengan shadow effect
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ENDLESS DODGE & COLLECT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.8),
                              blurRadius: 4,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Stats row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Best: ${widget.game.bestScore}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.circle,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${app.coins}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Hero Play Button (neumorphic, konsisten dengan gaya baru)
                    NeumorphicButton(
                      label: 'Play',
                      icon: Icons.play_arrow,
                      primary: true,
                      onPressed: () => widget.game.startGame(),
                    ),

                    const SizedBox.shrink(),

                    // Info untuk Settings
                    Offstage(
                      offstage: true,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.white60,
                              size: 20,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Untuk pengaturan Audio, Haptics, Ads, dan lainnya,\nbuka menu Settings di atas',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            // Quick Skin Preview (tetap ada karena berguna)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Active Skin:',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildActiveSkinPreview(
                                  context,
                                  app.activeSkinId,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// Tombol Daily Reward
                    Builder(
                      builder: (ctx) {
                        final cubit = ctx.read<AppSettingsCubit>();
                        final canClaim = cubit.canClaimDailyReward;
                        final countdown = _nextClaimCountdown(cubit);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            NeumorphicButton(
                              label: 'Daily Reward',
                              icon: Icons.card_giftcard,
                              primary: true,
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
                                        // Grant reward instantly without ad
                                        cubit.markDailyRewardClaimedNow();
                                        cubit.addCoins(rewardCoins);
                                        cubit.grantMagnetBuff(app.dailyMagnetBuffSeconds);
                                        LoggingService.log(
                                          'daily_reward_claimed',
                                          fields: {
                                            'coins': rewardCoins,
                                            'magnet_sec': app.dailyMagnetBuffSeconds,
                                            'via': 'no_ad',
                                          },
                                        );
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(ctx).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Daily reward: +${GameConfig.dailyRewardCoins} coins + magnet ${app.dailyMagnetBuffSeconds}s!',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                      : null,
                            ),
                            const SizedBox(height: 6),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: .4,
                                    ),
                                    child: Icon(
                                      Icons.brush,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed:
                                      () => _showSkinSelectionDialog(context),
                                ),
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: .4,
                                    ),
                                    child: Icon(
                                      Icons.emoji_events,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const AchievementsScreen(),
                                        ),
                                      ),
                                ),
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: .4,
                                    ),
                                    child: Icon(
                                      Icons.leaderboard_outlined,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed:
                                      () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  const LeaderboardScreen(),
                                        ),
                                      ),
                                ),
                                IconButton(
                                  icon: CircleAvatar(
                                    backgroundColor: Colors.grey.withValues(
                                      alpha: .4,
                                    ),
                                    child: Icon(
                                      Icons.tune,
                                      color: Colors.white,
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      barrierColor: AppTheme.barrierColorDark,
                                      builder:
                                          (ctx) => const Dialog(
                                            backgroundColor: Colors.transparent,
                                            child: OptionsPanel(),
                                          ),
                                    );
                                  },
                                ),
                              ],
                            ),
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
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showSkinSelectionDialog(BuildContext context) async {
    final cubit = context.read<AppSettingsCubit>();
    await showDialog<void>(
      context: context,
      barrierColor: AppTheme.barrierColorDark,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            final skins = cubit.getAllSkins();
            final activeId = cubit.state.activeSkinId;
            return AlertDialog(
              title: const Text('Pilih Skin Karakter'),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        skins.map((s) {
                          final isActive = s.id == activeId;
                          final status =
                              s.isUnlocked
                                  ? (isActive ? 'Selected' : 'Unlocked')
                                  : 'Locked';
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0x22000000),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: s.color,
                                    borderRadius: BorderRadius.circular(6),
                                    image:
                                        s.imagePath != null
                                            ? DecorationImage(
                                              image: AssetImage(
                                                "assets/images/${s.imagePath}",
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                            : null,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.isUnlocked
                                            ? status
                                            : 'Price: ${s.price} coins',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (!s.isUnlocked)
                                  ElevatedButton(
                                    onPressed: () {
                                      final ok = cubit.purchaseSkin(s.id);
                                      if (ok) {
                                        setSt(() {});
                                        // Add sound effect when purchasing skin
                                        if (cubit.state.audioOn) {
                                          try {
                                            final audioService =
                                                context.read<AudioService>();
                                            audioService
                                                .playCoin(); // Gunakan sound coin untuk purchase
                                          } catch (e) {
                                            // Abaikan jika AudioService tidak tersedia
                                            LoggingService.log(
                                              'Audio error: $e',
                                            );
                                          }
                                        }
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Unlocked: ${s.name}',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          const SnackBar(
                                            content: Text('Coins tidak cukup'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: Text('Buy (${s.price})'),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed:
                                        isActive
                                            ? null
                                            : () {
                                              cubit.setActiveSkin(s.id);
                                              setSt(() {});
                                              // Add sound effect when selecting skin
                                              if (cubit.state.audioOn) {
                                                try {
                                                  final audioService =
                                                      context
                                                          .read<AudioService>();
                                                  audioService
                                                      .playCoin(); // Gunakan sound coin untuk select
                                                } catch (e) {
                                                  // Abaikan jika AudioService tidak tersedia
                                                  LoggingService.log(
                                                    'Audio error: $e',
                                                  );
                                                }
                                              }
                                              ScaffoldMessenger.of(
                                                ctx,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Selected: ${s.name}',
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                    child: const Text('Select'),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
