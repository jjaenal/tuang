import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async' as dart_async;
import '../services/logging_service.dart';
import '../models/character_skin.dart';
import '../models/skin_type.dart';
import '../game/game_config.dart';
import 'package:flame/components.dart';
import '../game/skin_renderer.dart';
import 'leaderboard_screen.dart';
import 'options_panel.dart';
import 'achievements_screen.dart';
import 'components/bokeh_background.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Painter untuk preview skin berbasis canvas
class SkinPreviewPainter extends CustomPainter {
  final SkinType type;
  final Color color;
  final bool isBoost;

  late final SkinRenderer _renderer;

  SkinPreviewPainter({
    required this.type,
    required this.color,
    this.isBoost = false,
  }) {
    _renderer = SkinRenderer.create(type, color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    _renderer.render(
      canvas,
      Vector2(size.width, size.height),
      isBoost: isBoost,
    );
  }

  @override
  bool shouldRepaint(covariant SkinPreviewPainter oldDelegate) {
    return oldDelegate.type != type ||
        oldDelegate.color != color ||
        oldDelegate.isBoost != isBoost;
  }
}

/// Tombol besar bergaya neumorfik untuk aksi utama di menu.
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

/// Overlay menu utama berisi play, daily reward, skin, achievements, leaderboard, dan banner ads.
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
  dart_async.Timer? _ticker;
  DateTime _now = DateTime.now();

  bool _consentPrompted = false;

  /// Menampilkan dialog consent privasi dan mengembalikan pilihan pengguna.
  Future<bool> _showConsentDialog(BuildContext context) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final l10n = AppLocalizations.of(ctx);
        return AlertDialog(
          title: Text(l10n.consentDialogTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.consentDialogContent1),
                const SizedBox(height: 8),
                Text(l10n.consentDialogContent2),
                const SizedBox(height: 8),
                Text(l10n.consentDialogContent3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.consentDisagree),
            ),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(_privacyUrl);
                try {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              child: Text(l10n.privacyPolicy),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.consentAgree),
            ),
          ],
        );
      },
    );
    return accepted == true;
  }

  /// Menentukan apakah wilayah user memerlukan consent berdasarkan konfigurasi.
  bool _regionRequiresConsent() {
    // Gunakan konfigurasi dari GameConfig untuk menentukan kebutuhan consent.
    return GameConfig.alwaysRequireConsent;
  }

  /// Memulai ticker waktu dan memicu prompt consent setelah frame pertama.
  @override
  void initState() {
    super.initState();
    _ticker = dart_async.Timer.periodic(const Duration(seconds: 1), (_) {
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

  /// Membersihkan banner ad dan timer ketika overlay ditutup.
  @override
  void dispose() {
    _bannerAd?.dispose();
    _ticker?.cancel();
    _ticker = null;
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
        border: Border.all(color: Colors.white30),
        borderRadius: BorderRadius.circular(4),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CustomPaint(
            painter: SkinPreviewPainter(type: skin.skinType, color: skin.color),
          ),
        ),
      ),
    );
  }

  /// Membuat badge untuk menampilkan tipe skin dengan teks
  Widget _buildSkinTypeBadge(SkinType skinType) {
    Color badgeColor;
    String badgeText;

    switch (skinType) {
      case SkinType.basic:
        badgeColor = Colors.grey.shade700;
        badgeText = 'BASIC';
        break;
      case SkinType.advanced:
        badgeColor = Colors.blue.shade700;
        badgeText = 'ADVANCED';
        break;
      case SkinType.premium:
        badgeColor = Colors.purple.shade700;
        badgeText = 'PREMIUM';
        break;
      case SkinType.legendary:
        badgeColor = Colors.orange.shade700;
        badgeText = 'LEGENDARY';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: badgeColor.withOpacity(0.5),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        badgeText,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Membangun UI menu utama termasuk tombol aksi dan banner iklan.
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                      label: l10n.playButton,
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
                            Text(
                              l10n.settingsHint,
                              style: const TextStyle(
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
                                Text(
                                  l10n.activeSkin,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
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
                                        if (ctx.mounted) {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.dailyRewardSnack(
                                                  GameConfig.dailyRewardCoins,
                                                  app.dailyMagnetBuffSeconds,
                                                ),
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
                                l10n.nextClaim(countdown),
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
                              color: const Color(0x22FFFFFF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              l10n.loadingAds,
                              style: const TextStyle(color: Colors.white70),
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

  /// Dialog pemilihan/pembelian skin dengan preview, status, dan aksi.
  Future<void> _showSkinSelectionDialog(BuildContext context) async {
    final cubit = context.read<AppSettingsCubit>();
    await showDialog<void>(
      context: context,
      barrierColor: AppTheme.barrierColorDark,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSt) {
            final l10n = AppLocalizations.of(ctx);
            final skins = cubit.getAllSkins();
            final activeId = cubit.state.activeSkinId;
            return AlertDialog(
              title: Text(l10n.skinSelectTitle),
              content: SizedBox(
                width: 360,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children:
                        skins.map((s) {
                          final isActive = s.id == activeId;
                          final displayName = l10n.skinName(s.id);
                          final status =
                              s.isUnlocked
                                  ? (isActive
                                      ? l10n.selectedStatus
                                      : l10n.unlockedStatus)
                                  : l10n.lockedStatus;
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
                                Stack(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        boxShadow:
                                            s.skinType == SkinType.legendary
                                                ? [
                                                  BoxShadow(
                                                    color: Colors.orange
                                                        .withOpacity(0.6),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                  ),
                                                ]
                                                : null,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: SizedBox(
                                          width: 48,
                                          height: 48,
                                          child: CustomPaint(
                                            painter: SkinPreviewPainter(
                                              type: s.skinType,
                                              color: s.color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (s.skinType == SkinType.premium ||
                                        s.skinType == SkinType.legendary)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Icon(
                                          Icons.star,
                                          color:
                                              s.skinType == SkinType.legendary
                                                  ? Colors.amber
                                                  : Colors.white70,
                                          size: 16,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildSkinTypeBadge(s.skinType),
                                      const SizedBox(height: 2),
                                      Text(
                                        s.isUnlocked
                                            ? status
                                            : l10n.priceCoins(s.price),
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
                                        if (cubit.state.audioOn) {
                                          try {
                                            final audioService =
                                                context.read<AudioService>();
                                            audioService.playCoin();
                                          } catch (e) {
                                            LoggingService.log(
                                              'Audio error: $e',
                                            );
                                          }
                                        }
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              l10n.unlockedSnack(displayName),
                                            ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(ctx).showSnackBar(
                                          SnackBar(
                                            content: Text(l10n.notEnoughCoins),
                                          ),
                                        );
                                      }
                                    },
                                    // child: Text(l10n.buyButton(s.price)),
                                    child: Text(l10n.buyButton(s.price)),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed:
                                        isActive
                                            ? null
                                            : () {
                                              cubit.setActiveSkin(s.id);
                                              setSt(() {});
                                              if (cubit.state.audioOn) {
                                                try {
                                                  final audioService =
                                                      context
                                                          .read<AudioService>();
                                                  audioService.playCoin();
                                                } catch (e) {
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
                                                    l10n.selectedSnack(
                                                      displayName,
                                                    ),
                                                  ),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            },
                                    child: Text(l10n.selectButton),
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
                  child: Text(l10n.closeButton),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
