import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

class Coin extends RectangleComponent with HasGameReference<MyGame> {
  Coin({Vector2? position})
      : super(size: Vector2(16, 16), paint: Paint()..color = Colors.amber) {
    if (position != null) this.position = position;
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
  }
}