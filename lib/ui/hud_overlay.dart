import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/app_settings_cubit.dart';
import '../services/logging_service.dart';
import '../services/achievement_service.dart';

class HudOverlay extends StatefulWidget {
  final dynamic game;
  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay> {
  late final AchievementService _achievementService;

  @override
  void initState() {
    super.initState();
    _achievementService = AchievementService.I;
    _achievementService.onAchievementUnlocked.addListener(
      _onAchievementUnlocked,
    );
  }

  void _onAchievementUnlocked() {
    final unlocked = _achievementService.onAchievementUnlocked.value;
    if (unlocked != null && mounted) {
      _achievementService.showNotification(context, unlocked);
      // clear notifier to avoid repeat
      _achievementService.onAchievementUnlocked.value = null;
    }
  }

  @override
  void dispose() {
    _achievementService.onAchievementUnlocked.removeListener(
      _onAchievementUnlocked,
    );
    super.dispose();
  }

  /// Widget untuk membuat pill container dengan shadow dan gradient
  Widget _hudPill({
    required Widget child,
    Color? color,
    double radius = 12,
    EdgeInsets padding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    bool prominent = false,
  }) {
    final baseColor = color ?? const Color(0x88000000);
    
    return RepaintBoundary(
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: prominent 
            ? LinearGradient(
                colors: [
                  baseColor.withValues(alpha: 0.9),
                  baseColor.withValues(alpha: 0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: prominent ? null : baseColor,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: prominent ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
          border: prominent ? Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ) : null,
        ),
        child: child,
      ),
    );
  }

  /// Widget untuk skor yang menonjol dengan animasi glow
  Widget _buildProminentScore(int score) {
    return _hudPill(
      prominent: true,
      color: const Color(0xFF1A237E),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.star,
              color: Colors.amber,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$score',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: Colors.amber,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk timer dengan warna dinamis berdasarkan waktu
  Widget _buildDynamicTimer(int time) {
    // Warna berubah berdasarkan waktu: hijau -> kuning -> merah
    Color timerColor = Colors.green;
    Color bgColor = const Color(0xFF1B5E20);
    
    if (time <= 10) {
      timerColor = Colors.red;
      bgColor = const Color(0xFF8B0000);
    } else if (time <= 30) {
      timerColor = Colors.orange;
      bgColor = const Color(0xFFE65100);
    }

    return _hudPill(
      prominent: true,
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: timerColor,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(
            '${time}s',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: timerColor,
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Widget untuk magnet buff dengan progress visual yang lebih menarik
  Widget _buildMagnetBuff(double magnetProgress) {
    final isActive = magnetProgress > 0;
    
    return _hudPill(
      color: isActive ? const Color(0xFF00C853) : const Color(0x55666666),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon magnet dengan efek glow saat aktif
          Container(
             padding: const EdgeInsets.all(6),
             decoration: BoxDecoration(
               color: isActive 
                 ? Colors.greenAccent.withValues(alpha: 0.3)
                 : Colors.grey.withValues(alpha: 0.2),
               borderRadius: BorderRadius.circular(6),
             ),
            child: Icon(
              Icons.bolt,
              color: isActive ? Colors.greenAccent : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          
          // Progress bar dengan design yang lebih menarik
          Container(
            width: 80,
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0x33000000),
              border: Border.all(
                 color: isActive ? Colors.greenAccent.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.3),
                 width: 1,
               ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: LinearProgressIndicator(
                value: magnetProgress,
                backgroundColor: Colors.transparent,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isActive ? Colors.greenAccent : Colors.grey,
                ),
                minHeight: 10,
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Text countdown atau status
          Text(
            isActive ? '${widget.game.magnetSecondsLeft}s' : 'OFF',
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Top row: Skor menonjol dan Timer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Skor dengan design yang menonjol
                ValueListenableBuilder<int>(
                  valueListenable: game.scoreVN,
                  builder: (_, score, __) => _buildProminentScore(score),
                ),
                
                // Timer dengan warna dinamis
                ValueListenableBuilder<int>(
                  valueListenable: game.timeVN,
                  builder: (_, time, __) => _buildDynamicTimer(time),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Second row: Buff indicators dan controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side: Buff indicators
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Magnet buff dengan progress visual
                    ValueListenableBuilder<double>(
                      valueListenable: game.magnetVN,
                      builder: (_, mag, __) => _buildMagnetBuff(mag),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Combo multiplier
                    ValueListenableBuilder<int>(
                      valueListenable: game.comboVN,
                      builder: (_, combo, __) => _hudPill(
                        color: const Color(0xFF3F51B5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.flash_on,
                              color: Colors.lightBlueAccent,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'x$combo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Coins (persisten dari AppSettingsCubit)
                    BlocBuilder<AppSettingsCubit, AppSettingsState>(
                      builder: (context, app) => _hudPill(
                        color: const Color(0xFFFF8F00),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${app.coins}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Right side: Controls
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    BlocBuilder<AppSettingsCubit, AppSettingsState>(
                      builder: (context, app) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Pause/Resume button
                          _hudPill(
                            color: const Color(0x88333333),
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              tooltip: app.paused ? 'Resume' : 'Pause',
                              icon: Icon(
                                app.paused ? Icons.play_arrow : Icons.pause,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => context
                                  .read<AppSettingsCubit>()
                                  .setPaused(!app.paused),
                            ),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Audio toggle button
                          _hudPill(
                            color: const Color(0x88333333),
                            padding: const EdgeInsets.all(8),
                            child: IconButton(
                              tooltip: app.audioOn ? 'Mute' : 'Unmute',
                              icon: Icon(
                                app.audioOn ? Icons.volume_up : Icons.volume_off,
                                color: Colors.white,
                                size: 24,
                              ),
                              onPressed: () => context
                                  .read<AppSettingsCubit>()
                                  .toggleAudio(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Debug info (jika enabled)
                    if (LoggingService.enabled) ...[
                      const SizedBox(height: 8),
                      _hudPill(
                        color: const Color(0x55112233),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.bug_report,
                              color: Colors.lightBlueAccent,
                              size: 12,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'C:${game.coinsPicked} M:${game.magnetsPicked} R:${game.reviveCount}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
