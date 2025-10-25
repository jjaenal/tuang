import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../models/character_skin.dart';
import 'my_game.dart';
import 'skin_renderer.dart';

/// [Player] adalah karakter utama yang dapat dikontrol dalam game.
///
/// Komponen ini menangani pergerakan player berdasarkan input, membatasi posisi
/// dalam batas game, dan mengubah tampilan berdasarkan skin yang dipilih.
/// Player memiliki sistem boost visual dan dapat berubah skin secara dinamis.
///
/// Features:
/// - Pergerakan responsif berdasarkan input direction
/// - Sistem skin yang dapat diganti secara real-time
/// - Visual boost indicator saat speed multiplier aktif
/// - Boundary clamping untuk mencegah keluar dari area game
/// - Integrasi dengan SkinRenderer untuk rendering custom
///
/// Dependencies:
/// - Membutuhkan [CharacterSkin] untuk menentukan tampilan
/// - Menggunakan [SkinRenderer] untuk rendering visual
/// - Terintegrasi dengan [MyGame] untuk input dan game state
///
/// Example:
/// ```dart
/// final player = Player(skin: CharacterSkin.defaultSkin);
/// game.add(player);
/// ```
class Player extends PositionComponent with HasGameReference<MyGame> {
  /// Kecepatan dasar player dalam pixels per second
  final double speed = 200;

  /// Skin yang digunakan player untuk menentukan tampilan visual
  final CharacterSkin skin;

  /// Renderer untuk menggambar skin dengan berbagai efek visual
  late SkinRenderer _renderer;

  /// Status boost yang menentukan apakah player sedang dalam mode boost
  bool _isBoost = false;

  /// Membuat instance Player baru dengan skin yang ditentukan.
  ///
  /// [skin] menentukan tampilan visual player yang akan dirender.
  Player({required this.skin}) : super(size: Vector2(24, 24));

  @override
  Future<void> onLoad() async {
    anchor = Anchor.center;
    position = game.size / 2;

    // Inisialisasi renderer berdasarkan tipe skin dengan CustomPaint support
    _renderer = SkinRenderer.create(skin.skinType, skin.color, useCustomPaint: true);
  }

  /// Mengubah skin player secara dinamis saat game berjalan.
  ///
  /// Method ini memperbarui renderer untuk menggunakan skin baru tanpa
  /// memerlukan restart game atau recreate player component.
  ///
  /// [next] adalah skin baru yang akan digunakan player.
  void setSkin(CharacterSkin next) {
    _renderer = SkinRenderer.create(next.skinType, next.color, useCustomPaint: true);
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
