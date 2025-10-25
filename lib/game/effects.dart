import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

/// [FlashOverlay] adalah efek visual full-screen flash untuk collision feedback.
///
/// Komponen ini menampilkan overlay berwarna semi-transparan di seluruh layar
/// untuk memberikan feedback visual ketika terjadi collision atau event penting.
/// Overlay akan otomatis menghilang setelah durasi yang ditentukan.
///
/// Parameters:
/// - [size]: Ukuran overlay (biasanya ukuran layar)
/// - [color]: Warna overlay dengan alpha untuk transparansi
/// - [durationMs]: Durasi tampil dalam milliseconds
class FlashOverlay extends RectangleComponent {
  FlashOverlay({
    required Vector2 size,
    Color color = const Color(0x55FF0000),
    int durationMs = 200,
  }) : super(size: size, paint: Paint()..color = color, priority: 10) {
    Future.delayed(Duration(milliseconds: durationMs), () {
      removeFromParent();
    });
  }
}

/// [MagnetGlow] adalah efek visual yang mengikuti player ketika magnet buff aktif.
///
/// Menampilkan lingkaran glow berwarna hijau di sekitar player untuk memberikan
/// indikasi visual bahwa magnet power-up sedang aktif. Posisi glow akan selalu
/// mengikuti posisi player secara real-time.
///
/// Dependencies:
/// - Membutuhkan referensi ke [Player] target untuk tracking posisi
class MagnetGlow extends CircleComponent {
  /// Player target yang akan diikuti oleh glow effect
  final Player target;

  MagnetGlow({required this.target})
    : super(
        radius: 50,
        paint:
            Paint()
              ..color = const Color(0x442ECC71)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
        anchor: Anchor.center,
      );

  /// Update posisi glow agar selalu mengikuti posisi player target.
  @override
  void update(double dt) {
    super.update(dt);
    position = target.position;
  }
}

/// [SpeedBoostGlow] adalah efek visual yang mengikuti player ketika speed boost aktif.
///
/// Menampilkan lingkaran glow berwarna merah di sekitar player untuk memberikan
/// indikasi visual bahwa speed boost power-up sedang aktif. Ukuran lebih kecil
/// dari MagnetGlow untuk membedakan jenis buff yang aktif.
///
/// Dependencies:
/// - Membutuhkan referensi ke [Player] target untuk tracking posisi
class SpeedBoostGlow extends CircleComponent {
  /// Player target yang akan diikuti oleh glow effect
  final Player target;

  SpeedBoostGlow({required this.target})
    : super(
        radius: 30,
        paint:
            Paint()
              ..color = const Color(0x40E74C3C)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
        anchor: Anchor.center,
      );

  @override
  void update(double dt) {
    super.update(dt);
    position = target.position;
  }
}

/// ShieldGlow: visual effect that follows player when shield is active
class ShieldGlow extends CircleComponent {
  final Player target;

  ShieldGlow({required this.target})
    : super(
        radius: 25,
        paint:
            Paint()
              ..color = const Color(0x443498DB)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.0,
        anchor: Anchor.center,
      );

  @override
  void update(double dt) {
    super.update(dt);
    position = target.position;
  }
}

class PopEffect extends RectangleComponent {
  final double duration;
  double _elapsed = 0;
  final double startSize;
  final double endSize;
  final Color color;

  PopEffect({
    required Vector2 position,
    this.duration = 0.25,
    this.startSize = 6,
    this.endSize = 22,
    this.color = const Color(0xFFFFC107),
  }) : super(
         position: position,
         size: Vector2.all(6),
         paint: Paint()..color = color,
       ) {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    final s = startSize + (endSize - startSize) * t;
    size = Vector2.all(s);
    final alpha = 1.0 - t;
    paint.color = color.withValues(alpha: alpha);
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}

class FloatingText extends TextComponent {
  final double duration;
  double _elapsed = 0;
  final Vector2 velocity;
  final Color color;

  FloatingText({
    required Vector2 position,
    String text = '+1',
    this.duration = 0.6,
    Vector2? velocity,
    this.color = Colors.white,
  }) : velocity = velocity ?? Vector2(0, -60),
       super(
         text: text,
         position: position,
         textRenderer: TextPaint(
           style: const TextStyle(
             color: Colors.white,
             fontSize: 12,
             fontWeight: FontWeight.bold,
           ),
         ),
       ) {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position += velocity * dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    final alpha = 1.0 - t;
    final current = (textRenderer as TextPaint).style;
    textRenderer = TextPaint(
      style: current.copyWith(color: color.withValues(alpha: alpha)),
    );
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
