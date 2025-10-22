import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/character_skin.dart';
import 'my_game.dart';
import '../services/logging_service.dart';

/// Player: controllable sprite that moves with input direction,
/// clamps within game bounds, and changes appearance based on selected skin.
class Player extends SpriteComponent with HasGameReference<MyGame> {
  final double speed = 200;

  // Skin yang digunakan player
  final CharacterSkin skin;

  // Warna default untuk fallback jika sprite gagal dimuat
  Color _defaultColor = Colors.blue;
  Color _boostColor = Colors.cyan;

  Player({required this.skin}) : super(size: Vector2(24, 24));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = game.size / 2;

    // Set warna berdasarkan skin
    _defaultColor = skin.color;
    _boostColor = skin.color.withValues(alpha: 0.7);

    // Coba muat sprite berdasarkan skin
    try {
      final skinImage = skin.imagePath;
      if (skinImage != null) {
        sprite = await game.loadSprite(skinImage);
      }
    } catch (e) {
      // Fallback ke rectangle jika gagal memuat sprite
      LoggingService.log(
        'player_sprite_load_failed',
        fields: {'error': e.toString()},
      );
    }
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

    // Jika tidak ada sprite, gunakan warna sebagai visual feedback
    if (sprite == null) {
      paint.color =
          game.playerSpeedMultiplier > 1.0 ? _boostColor : _defaultColor;
    } else {
      // Jika ada sprite, bisa mengubah opacity atau skala untuk efek boost
      opacity = game.playerSpeedMultiplier > 1.0 ? 0.8 : 1.0;
      scale =
          game.playerSpeedMultiplier > 1.0
              ? Vector2.all(1.1)
              : Vector2.all(1.0);
    }

    position = Vector2(
      position.x.clamp(size.x / 2, game.size.x - size.x / 2),
      position.y.clamp(size.y / 2, game.size.y - size.y / 2),
    );
  }
}
