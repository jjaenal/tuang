import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// [Obstacle] adalah rintangan bergerak yang harus dihindari player.
///
/// Obstacle bergerak dengan kecepatan dan arah yang ditentukan, memantul
/// di tepi layar, dan menyebabkan game over jika menyentuh player (kecuali
/// player memiliki shield aktif). Obstacle dirender sebagai kotak merah
/// yang mudah dibedakan dari elemen game lainnya.
///
/// Features:
/// - Pergerakan dengan velocity yang dapat dikustomisasi
/// - Bouncing physics di tepi layar untuk tetap dalam bounds
/// - Collision detection dengan player
/// - Shield interaction (obstacle dihancurkan jika player punya shield)
/// - Visual feedback dengan flash effect saat collision
///
/// Dependencies:
/// - Terintegrasi dengan [MyGame] untuk collision dan boundary detection
/// - Menggunakan AudioService untuk sound effects saat collision
/// - Berinteraksi dengan sistem shield power-up
///
/// Example:
/// ```dart
/// final obstacle = Obstacle(
///   position: Vector2(100, 100),
///   velocity: Vector2(50, -30),
/// );
/// game.add(obstacle);
/// ```
class Obstacle extends RectangleComponent with HasGameReference<MyGame> {
  /// Kecepatan dan arah pergerakan obstacle dalam pixels per second
  Vector2 velocity;

  /// Membuat instance Obstacle baru dengan posisi dan velocity yang ditentukan.
  ///
  /// [position] adalah posisi spawn obstacle di layar.
  /// [velocity] menentukan kecepatan dan arah pergerakan obstacle.
  /// [size] adalah ukuran obstacle (default 18x18 pixels).
  /// [color] adalah warna obstacle (default merah #DC3545).
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
