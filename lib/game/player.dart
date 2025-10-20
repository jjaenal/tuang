import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// Player: controllable rectangle that moves with input direction,
/// clamps within game bounds, and changes color during speed boost.
class Player extends RectangleComponent with HasGameReference<MyGame> {
  final double speed = 200;

  Player() : super(size: Vector2(24, 24), paint: Paint()..color = Colors.blue);

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = game.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = game.inputDir.clone();
    if (delta.length2 > 0) {
      delta.normalize();
      final currentSpeed = speed * game.playerSpeedMultiplier;
      position += delta * currentSpeed * dt;
    }

    // visual feedback for boost
    paint.color = game.playerSpeedMultiplier > 1.0 ? Colors.cyan : Colors.blue;

    position = Vector2(
      position.x.clamp(size.x / 2, game.size.x - size.x / 2),
      position.y.clamp(size.y / 2, game.size.y - size.y / 2),
    );
  }
}
