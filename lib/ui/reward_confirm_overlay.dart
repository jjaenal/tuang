import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../game/my_game.dart';
import '../state/app_settings_cubit.dart';
import '../services/logging_service.dart';
import '../services/leaderboard_service.dart';
import '../services/audio_service.dart';
import '../services/haptics_service.dart';
import 'components/neumorphic_button.dart';
import 'components/menu_components.dart';
import 'components/bokeh_background.dart';
import 'theme/app_theme.dart';
import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RewardConfirmOverlay extends StatefulWidget {
  final MyGame game;
  const RewardConfirmOverlay({super.key, required this.game});

  @override
  State<RewardConfirmOverlay> createState() => _RewardConfirmOverlayState();
}

class _RewardConfirmOverlayState extends State<RewardConfirmOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  // Confetti
  late final AnimationController _confettiController;
  final Random _rand = Random();
  List<_Particle> _particles = [];

  MyGame get game => widget.game;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );
    final curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _opacity = curve;
    _scale = Tween<double>(begin: 0.95, end: 1.0).animate(curve);
    _controller.forward();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _animateExit() async {
    try {
      await _controller.reverse();
    } catch (_) {}
  }

  void _regenParticles([int count = 28]) {
    _particles = List.generate(count, (_) {
      // Start near top-center area
      final x0 = 0.35 + _rand.nextDouble() * 0.30; // 35%..65%
      final y0 = 0.30 + _rand.nextDouble() * 0.10; // 30%..40%
      // Drift velocities
      final vx = (_rand.nextDouble() - 0.5) * 0.6; // -0.3..0.3
      final vy = 0.6 + _rand.nextDouble() * 0.6; // 0.6..1.2 downward
      // Size and color
      final size = 3.0 + _rand.nextDouble() * 3.0;
      final colors = [
        Colors.amber,
        Colors.cyanAccent,
        Colors.pinkAccent,
        Colors.greenAccent,
        Colors.orangeAccent,
        Colors.lightBlueAccent,
      ];
      final color = colors[_rand.nextInt(colors.length)];
      final spin = (_rand.nextDouble() - 0.5) * pi; // -pi/2..pi/2
      return _Particle(x0, y0, vx, vy, size, color, spin);
    });
  }

  Future<void> _playConfetti() async {
    _regenParticles();
    _confettiController.reset();
    _confettiController.forward();
    // Tampilkan konfeti singkat tanpa menahan terlalu lama
    await Future.delayed(const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    final base = game.baseScoreAtGameOver;
    final total = game.lastScore;
    final l10n = AppLocalizations.of(context);
    final tTitle = l10n?.doubleRewardTitle ?? 'Double Reward';
    final tApplied = l10n?.doubleCoinsApplied ?? 'Double Coins diterapkan!';
    String tBase(int v) => l10n?.baseCoinsLabel(v) ?? 'Base: +$v';
    String tBonus(int v) => l10n?.bonusDoubleLabel(v) ?? 'Bonus Double: +$v';
    String tTotal(int v) => l10n?.totalCoinsLabel(v) ?? 'Total: +$v coins';
    final tContinue = l10n?.continuePlay ?? 'Lanjut main';
    final tBackHome = l10n?.backHome ?? 'Kembali ke Home';

    return Stack(
      children: [
        const BokehBackground(
          backgroundColor: Colors.black,
          bokehCount: 10,
          intensity: 0.5,
        ),
        Positioned.fill(child: Container(color: AppTheme.barrierColorDark)),
        SafeArea(
          child: Align(
            alignment: Alignment.center,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                FadeTransition(
                  opacity: _opacity,
                  child: ScaleTransition(
                    scale: _scale,
                    child: MenuPanel(
                      title: tTitle,
                      dark: true,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                tApplied,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Breakdown base + bonus = total
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.savings, color: Colors.amber, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    tBase(base),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.auto_awesome, color: Colors.lightBlueAccent, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    tBonus(base),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.greenAccent, size: 18),
                                  const SizedBox(width: 6),
                                  Text(
                                    tTotal(total),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        NeumorphicButton(
                          label: tContinue,
                          primary: false,
                          onPressed: () async {
                            LoggingService.log('double_confirm_continue');
                            final cubit = context.read<AppSettingsCubit>();
                            if (!game.rewardDeposited) {
                              cubit.addCoins(total);
                              game.markRewardDeposited();
                              // SFX + haptik saat reward diterapkan
                              AudioService.I.playCoin();
                              HapticsService.coinPickup();
                              final leaderboard = LeaderboardService();
                              await leaderboard.submitScoreAsync(
                                playerId: cubit.state.playerName,
                                score: total,
                              );
                              LoggingService.log(
                                'reward_deposited',
                                fields: {'amount': total, 'action': 'restart_from_double'},
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tTotal(total))),
                                );
                              }
                            }
                            await _playConfetti();
                            await _animateExit();
                            game.overlays.remove(MyGame.overlayRewardConfirm);
                            game.overlays.remove(MyGame.overlayGameOver);
                            game.startGame();
                          },
                        ),
                        const SizedBox(height: 8),
                        NeumorphicButton(
                          label: tBackHome,
                          icon: Icons.home,
                          primary: false,
                          onPressed: () async {
                            LoggingService.log('double_confirm_home');
                            final cubit = context.read<AppSettingsCubit>();
                            if (!game.rewardDeposited) {
                              cubit.addCoins(total);
                              game.markRewardDeposited();
                              // SFX + haptik saat reward diterapkan
                              AudioService.I.playCoin();
                              HapticsService.coinPickup();
                              final leaderboard = LeaderboardService();
                              await leaderboard.submitScoreAsync(
                                playerId: cubit.state.playerName,
                                score: total,
                              );
                              LoggingService.log(
                                'reward_deposited',
                                fields: {'amount': total, 'action': 'back_to_menu_from_double'},
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(tTotal(total))),
                                );
                              }
                            }
                            await _playConfetti();
                            await _animateExit();
                            game.overlays.remove(MyGame.overlayRewardConfirm);
                            game.overlays.remove(MyGame.overlayGameOver);
                            game.overlays.add(MyGame.overlayMainMenu);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                // Confetti layer on top
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (context, _) => CustomPaint(
                        painter: _ConfettiPainter(_particles, _confettiController.value),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Particle {
  final double x0;
  final double y0;
  final double vx;
  final double vy;
  final double size;
  final Color color;
  final double spin;
  _Particle(this.x0, this.y0, this.vx, this.vy, this.size, this.color, this.spin);
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double t; // 0..1 progress
  _ConfettiPainter(this.particles, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final x = (p.x0 * size.width) + (p.vx * t * size.width * 0.25);
      final y = (p.y0 * size.height) + (p.vy * t * size.height * 0.45);
      final opacity = (1.0 - t).clamp(0.0, 1.0);
      paint.color = p.color.withOpacity(opacity);
      // Draw small circle as confetti piece
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.particles != particles;
  }
}