import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// SpeedBoostPowerUp: pickup yang memberikan speed boost untuk durasi tertentu.
/// Player bergerak lebih cepat dan bisa menghindari obstacle dengan lebih mudah.
class SpeedBoostPowerUp extends RectangleComponent
    with HasGameReference<MyGame> {
  SpeedBoostPowerUp({Vector2? position, Color color = const Color(0xFFE74C3C)})
    : super(size: Vector2(18, 18), paint: Paint()..color = color) {
    if (position != null) this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Bisa ditambahkan animasi atau glow effect nanti
  }
}
