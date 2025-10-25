import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'my_game.dart';

/// [Coin] adalah item kolektibel yang dapat dikumpulkan player untuk mendapatkan poin.
///
/// Ketika player menyentuh coin, akan memicu berbagai efek gameplay termasuk
/// peningkatan skor, speed boost sementara, dan sistem combo. Coin dirender
/// sebagai kotak kecil berwarna amber yang mudah terlihat di layar.
///
/// Features:
/// - Memberikan poin saat dikumpulkan
/// - Memicu speed boost sementara pada player
/// - Berkontribusi pada sistem combo multiplier
/// - Visual feedback dengan efek partikel dan suara
/// - Dapat ditarik oleh magnet power-up
///
/// Dependencies:
/// - Terintegrasi dengan [MyGame] untuk collision detection
/// - Menggunakan AudioService untuk sound effects
/// - Berinteraksi dengan sistem combo dan achievement
///
/// Example:
/// ```dart
/// final coin = Coin(position: Vector2(100, 100));
/// game.add(coin);
/// ```
class Coin extends RectangleComponent with HasGameReference<MyGame> {
  /// Membuat instance Coin baru pada posisi yang ditentukan.
  ///
  /// [position] adalah posisi spawn coin di layar. Jika null, coin akan
  /// ditempatkan pada posisi default (0,0) dan perlu diatur manual.
  Coin({Vector2? position})
    : super(size: Vector2(16, 16), paint: Paint()..color = Colors.amber) {
    if (position != null) this.position = position;
  }

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
  }
}
