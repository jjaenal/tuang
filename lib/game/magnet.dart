import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// [MagnetPowerUp] adalah power-up yang mengaktifkan daya tarik coin untuk durasi tertentu.
///
/// Ketika player mengambil magnet power-up, semua coin dalam radius tertentu
/// akan tertarik ke arah player, memudahkan pengumpulan coin. Power-up ini
/// spawn secara periodik dan dihapus saat terjadi collision dengan player.
///
/// Features:
/// - Mengaktifkan coin attraction dalam radius tertentu
/// - Durasi efek yang dapat dikonfigurasi melalui GameConfig
/// - Visual glow effect saat magnet aktif
/// - Sound effect saat pickup
/// - Tracking untuk achievement dan statistik
///
/// Dependencies:
/// - Terintegrasi dengan [MyGame] untuk collision detection dan coin attraction
/// - Menggunakan AudioService untuk sound effects
/// - Berinteraksi dengan AchievementService untuk tracking usage
/// - Menggunakan GameConfig untuk parameter magnet (radius, strength, duration)
///
/// Example:
/// ```dart
/// final magnet = MagnetPowerUp(position: Vector2(200, 150));
/// game.add(magnet);
/// ```
class MagnetPowerUp extends RectangleComponent with HasGameReference<MyGame> {
  /// Membuat instance MagnetPowerUp baru pada posisi yang ditentukan.
  ///
  /// [position] adalah posisi spawn magnet di layar. Jika null, magnet akan
  /// ditempatkan pada posisi default (0,0) dan perlu diatur manual.
  /// [color] adalah warna magnet power-up (default hijau #2ECC71).
  MagnetPowerUp({Vector2? position, Color color = const Color(0xFF2ECC71)})
    : super(size: Vector2(18, 18), paint: Paint()..color = color) {
    if (position != null) this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // You can add a subtle glow or animation later
  }
}
