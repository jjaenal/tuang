import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// MagnetPowerUp: pickup that activates coin attraction for a fixed duration.
/// Spawned periodically by MyGame and removed on player collision.
class MagnetPowerUp extends RectangleComponent with HasGameReference<MyGame> {
  MagnetPowerUp({Vector2? position, Color color = const Color(0xFF2ECC71)})
    : super(size: Vector2(18, 18), paint: Paint()..color = color) {
    if (position != null) this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // You can add a subtle glow or animation later
  }
}
