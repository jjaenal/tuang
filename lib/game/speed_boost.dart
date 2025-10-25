import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// [SpeedBoostPowerUp] adalah power-up yang memberikan peningkatan kecepatan untuk durasi tertentu.
///
/// Ketika player mengambil speed boost power-up, kecepatan pergerakan akan
/// meningkat secara signifikan, memudahkan player untuk menghindari obstacle
/// dan mengumpulkan coin dengan lebih efisien. Power-up ini spawn secara
/// periodik dan dihapus saat terjadi collision dengan player.
///
/// Features:
/// - Meningkatkan kecepatan player untuk durasi tertentu
/// - Visual glow effect saat speed boost aktif
/// - Dapat dikombinasikan dengan speed boost dari coin pickup
/// - Durasi yang dapat dikonfigurasi melalui GameConfig
/// - Visual feedback dengan warna merah yang mencolok
///
/// Dependencies:
/// - Terintegrasi dengan [MyGame] untuk collision detection dan speed management
/// - Menggunakan GameConfig untuk parameter speed boost (multiplier, duration)
/// - Berinteraksi dengan sistem visual effects (SpeedBoostGlow)
///
/// Example:
/// ```dart
/// final speedBoost = SpeedBoostPowerUp(position: Vector2(150, 200));
/// game.add(speedBoost);
/// ```
class SpeedBoostPowerUp extends RectangleComponent
    with HasGameReference<MyGame> {
  /// Membuat instance SpeedBoostPowerUp baru pada posisi yang ditentukan.
  ///
  /// [position] adalah posisi spawn speed boost di layar. Jika null, power-up akan
  /// ditempatkan pada posisi default (0,0) dan perlu diatur manual.
  /// [color] adalah warna speed boost power-up (default merah #E74C3C).
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
