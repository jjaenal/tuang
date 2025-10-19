import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Obstacle extends RectangleComponent with HasGameReference<MyGame> {
  Vector2 velocity;

  Obstacle({
    required Vector2 position,
    required this.velocity,
    Vector2? size,
    Color color = const Color(0xFFDC3545),
  }) : super(
          position: position,
          size: size ?? Vector2(18, 18),
          paint: Paint()..color = color,
        ) {
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;

    // bounce on borders
    final half = size / 2;
    if (position.x < half.x) {
      position.x = half.x;
      velocity.x = velocity.x.abs();
    } else if (position.x > game.size.x - half.x) {
      position.x = game.size.x - half.x;
      velocity.x = -velocity.x.abs();
    }

    if (position.y < half.y) {
      position.y = half.y;
      velocity.y = velocity.y.abs();
    } else if (position.y > game.size.y - half.y) {
      position.y = game.size.y - half.y;
      velocity.y = -velocity.y.abs();
    }
  }
}