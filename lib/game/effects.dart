import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'player.dart';

/// FlashOverlay: full-screen flash effect for collisions
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

/// MagnetGlow: visual effect that follows player when magnet is active
class MagnetGlow extends CircleComponent {
  final Player target;

  MagnetGlow({required this.target})
      : super(
          radius: 50,
          paint: Paint()
            ..color = const Color(0x442ECC71)
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

/// SpeedBoostGlow: visual effect that follows player when speed boost is active
class SpeedBoostGlow extends CircleComponent {
  final Player target;

  SpeedBoostGlow({required this.target})
      : super(
          radius: 30,
          paint: Paint()
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
          paint: Paint()
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
