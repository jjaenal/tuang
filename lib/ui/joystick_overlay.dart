import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../game/my_game.dart';
import 'theme/app_theme.dart';

/// [JoystickOverlay] adalah overlay yang menampilkan joystick dinamis untuk kontrol touch.
///
/// Joystick akan muncul saat user melakukan touch pertama kali dan menghilang
/// saat touch dilepas. Posisi joystick mengikuti posisi touch awal untuk
/// memberikan kontrol yang natural dan responsif.
///
/// Features:
/// - Dynamic positioning berdasarkan touch location
/// - Auto show/hide berdasarkan touch state
/// - Smooth fade in/out animation
/// - Integrated dengan MyGame input system
/// - Responsive design untuk berbagai ukuran layar
///
/// Dependencies:
/// - Menggunakan [MyGame] untuk input direction
/// - Terintegrasi dengan [JoystickComponent] dari Flame
/// - Menggunakan [AppTheme] untuk styling konsisten
///
/// Example:
/// ```dart
/// overlays.add('JoystickOverlay');
/// ```
class JoystickOverlay extends StatefulWidget {
  /// Instance game untuk input handling
  final MyGame game;

  const JoystickOverlay({super.key, required this.game});

  @override
  State<JoystickOverlay> createState() => _JoystickOverlayState();
}

class _JoystickOverlayState extends State<JoystickOverlay>
    with TickerProviderStateMixin {
  /// Controller untuk fade animation
  late AnimationController _fadeController;
  
  /// Animation untuk opacity joystick
  late Animation<double> _fadeAnimation;
  
  /// Posisi joystick saat ini (null = hidden)
  Offset? _joystickPosition;
  
  /// Apakah joystick sedang aktif (untuk future use)
  // bool _isActive = false;
  
  /// Radius area joystick
  static const double _joystickRadius = 60.0;
  
  /// Radius knob joystick
  static const double _knobRadius = 20.0;
  
  /// Posisi knob relatif terhadap center joystick
  Offset _knobOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    
    // Setup fade animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Menampilkan joystick pada posisi tertentu
  void _showJoystick(Offset position) {
    setState(() {
      _joystickPosition = position;
      _knobOffset = Offset.zero;
    });
    _fadeController.forward();
  }

  /// Menyembunyikan joystick
  void _hideJoystick() {
    _fadeController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _joystickPosition = null;
          _knobOffset = Offset.zero;
        });
        // Reset input direction saat joystick disembunyikan
        widget.game.inputDirTarget = Vector2.zero();
      }
    });
  }

  /// Update posisi knob dan input direction
  void _updateKnob(Offset globalPosition) {
    if (_joystickPosition == null) return;
    
    final center = _joystickPosition!;
    final delta = globalPosition - center;
    final distance = delta.distance;
    
    // Batasi knob dalam radius joystick
    if (distance <= _joystickRadius) {
      _knobOffset = delta;
    } else {
      // Clamp ke edge joystick
      final direction = delta / distance;
      _knobOffset = direction * _joystickRadius;
    }
    
    // Update input direction untuk game
    final normalizedInput = Vector2(
      _knobOffset.dx / _joystickRadius,
      _knobOffset.dy / _joystickRadius,
    );
    
    // Apply deadzone untuk menghindari jitter
    const double deadzone = 0.15;
    if (normalizedInput.length >= deadzone) {
      // Gunakan magnitude sebagai analog kecepatan; smoothing terjadi di MyGame
      widget.game.inputDirTarget = normalizedInput;
    } else {
      widget.game.inputDirTarget = Vector2.zero();
    }
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        // Tampilkan joystick pada posisi touch
        _showJoystick(details.globalPosition);
      },
      onPanUpdate: (details) {
        // Update posisi knob
        _updateKnob(details.globalPosition);
      },
      onPanEnd: (details) {
        // Sembunyikan joystick
        _hideJoystick();
      },
      onPanCancel: () {
        // Sembunyikan joystick jika gesture dibatalkan
        _hideJoystick();
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            if (_joystickPosition == null || _fadeAnimation.value == 0) {
              return const SizedBox.shrink();
            }
            
            return Stack(
              children: [
                // Joystick base
                Positioned(
                  left: _joystickPosition!.dx - _joystickRadius,
                  top: _joystickPosition!.dy - _joystickRadius,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: _joystickRadius * 2,
                      height: _joystickRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.darkBase.withValues(alpha: 0.3),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
                // Joystick knob
                Positioned(
                  left: _joystickPosition!.dx + _knobOffset.dx - _knobRadius,
                  top: _joystickPosition!.dy + _knobOffset.dy - _knobRadius,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: _knobRadius * 2,
                      height: _knobRadius * 2,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
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