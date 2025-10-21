import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// ShieldPowerUp: pickup yang memberikan shield protection untuk durasi tertentu.
/// Player bisa menabrak obstacle sekali tanpa game over.
class ShieldPowerUp extends RectangleComponent with HasGameReference<MyGame> {
  ShieldPowerUp({Vector2? position, Color color = const Color(0xFF3498DB)})
    : super(size: Vector2(18, 18), paint: Paint()..color = color) {
    if (position != null) this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Bisa ditambahkan animasi atau glow effect nanti
  }
}
