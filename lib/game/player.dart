import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/character_skin.dart';
import 'my_game.dart';
import 'skin_renderer.dart';

/// Player: controllable sprite that moves with input direction,
/// clamps within game bounds, and changes appearance based on selected skin.
class Player extends PositionComponent with HasGameReference<MyGame> {
  final double speed = 200;

  // Skin yang digunakan player
  final CharacterSkin skin;

  // Renderer untuk menggambar skin
  late SkinRenderer _renderer;

  // Status boost
  bool _isBoost = false;

  Player({required this.skin}) : super(size: Vector2(24, 24));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = game.size / 2;

    // Inisialisasi renderer berdasarkan tipe skin
    _renderer = SkinRenderer.create(skin.skinType, skin.color);
  }

  // Update skin renderer saat pemain memulai game atau mengganti skin aktif
  void setSkin(CharacterSkin next) {
    _renderer = SkinRenderer.create(next.skinType, next.color);
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

    // Update status boost
    _isBoost = game.playerSpeedMultiplier > 1.0;

    position = Vector2(
      position.x.clamp(size.x / 2, game.size.x - size.x / 2),
      position.y.clamp(size.y / 2, game.size.y - size.y / 2),
    );
  }

  @override
  void render(Canvas canvas) {
    // Gunakan renderer untuk menggambar skin
    _renderer.render(canvas, size, isBoost: _isBoost);
  }
}
