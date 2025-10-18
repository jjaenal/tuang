import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Player extends RectangleComponent with HasGameRef<MyGame> {
  final double speed = 200;

  Player() : super(size: Vector2(24, 24), paint: Paint()..color = Colors.blue);

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = gameRef.size / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final delta = gameRef.inputDir.clone();
    if (delta.length2 > 0) {
      delta.normalize();
      final currentSpeed = speed * gameRef.playerSpeedMultiplier;
      position += delta * currentSpeed * dt;
    }

    // visual feedback for boost
    paint.color = gameRef.playerSpeedMultiplier > 1.0 ? Colors.cyan : Colors.blue;

    position = Vector2(
      position.x.clamp(size.x / 2, gameRef.size.x - size.x / 2),
      position.y.clamp(size.y / 2, gameRef.size.y - size.y / 2),
    );
  }
}