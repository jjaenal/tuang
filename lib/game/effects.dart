import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PopEffect extends RectangleComponent {
  final double duration;
  double _elapsed = 0;
  final double startSize;
  final double endSize;
  final Color color;

  PopEffect({
    required Vector2 position,
    this.duration = 0.25,
    this.startSize = 4,
    this.endSize = 24,
    this.color = Colors.amber,
  }) : super(
         position: position,
         size: Vector2.all(4),
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
    final opacity = 1.0 - t;
    paint.color = color.withValues(alpha: opacity);
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
    final opacity = 1.0 - t;
    final current = (textRenderer as TextPaint).style;
    textRenderer = TextPaint(
      style: current.copyWith(color: color.withValues(alpha: opacity)),
    );
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}

class FlashOverlay extends RectangleComponent {
  final double duration;
  double _elapsed = 0;
  final Color color;

  FlashOverlay({
    required Vector2 size,
    this.duration = 0.12,
    this.color = Colors.white,
  }) : super(
         size: size,
         position: Vector2.zero(),
         paint: Paint()..color = color.withValues(alpha: 0.0),
       ) {
    anchor = Anchor.topLeft;
    priority = 1000;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha: 1.0 - t);
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}

class DotParticle extends RectangleComponent {
  final double duration;
  double _elapsed = 0;
  Vector2 velocity;
  final Color color;

  DotParticle({
    required Vector2 position,
    required this.velocity,
    this.duration = 0.5,
    this.color = Colors.amber,
  }) : super(
         position: position,
         size: Vector2.all(3),
         paint: Paint()..color = color,
       ) {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;
    position += velocity * dt;
    velocity *= 0.98; // simple damping
    final t = (_elapsed / duration).clamp(0.0, 1.0);
    paint.color = color.withValues(alpha: 1.0 - t);
    if (_elapsed >= duration) {
      removeFromParent();
    }
  }
}
