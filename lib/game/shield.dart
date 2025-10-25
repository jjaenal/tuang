import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// [ShieldPowerUp] adalah power-up yang memberikan perlindungan shield untuk durasi tertentu.
///
/// Ketika player mengambil shield power-up, akan mendapatkan perlindungan yang
/// memungkinkan player menabrak obstacle sekali tanpa menyebabkan game over.
/// Shield akan otomatis hilang setelah menyerap satu collision atau durasi habis.
/// Power-up ini spawn secara periodik dan dihapus saat terjadi collision dengan player.
///
/// Features:
/// - Memberikan perlindungan dari satu collision dengan obstacle
/// - Visual glow effect biru saat shield aktif
/// - Durasi yang dapat dikonfigurasi melalui GameConfig
/// - Visual feedback dengan flash effect biru saat shield menyerap damage
/// - Automatic cleanup setelah digunakan atau expired
///
/// Dependencies:
/// - Terintegrasi dengan [MyGame] untuk collision detection dan shield management
/// - Menggunakan GameConfig untuk parameter shield (duration)
/// - Berinteraksi dengan sistem visual effects (ShieldGlow, FlashOverlay)
/// - Menggunakan AudioService untuk sound effects saat shield absorbs hit
///
/// Example:
/// ```dart
/// final shield = ShieldPowerUp(position: Vector2(180, 120));
/// game.add(shield);
/// ```
class ShieldPowerUp extends RectangleComponent with HasGameReference<MyGame> {
  /// Membuat instance ShieldPowerUp baru pada posisi yang ditentukan.
  ///
  /// [position] adalah posisi spawn shield di layar. Jika null, power-up akan
  /// ditempatkan pada posisi default (0,0) dan perlu diatur manual.
  /// [color] adalah warna shield power-up (default biru #3498DB).
  ShieldPowerUp({Vector2? position, Color color = const Color(0xFF3498DB)})
    : super(size: Vector2(18, 18), paint: Paint()..color = color) {
    if (position != null) this.position = position;
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Bisa ditambahkan animasi atau glow effect nanti
  }
}
