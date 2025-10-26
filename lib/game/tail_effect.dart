import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'player.dart';

/// TailEffect menggambar jejak (trail) halus di belakang player.
///
/// Mekanisme: menyimpan sejumlah titik posisi player dan menggambar
/// garis bersegmen dengan alpha berkurang untuk menciptakan efek fade.
class TailEffect extends PositionComponent {
  final Player target;
  Color _color;
  final int maxPoints;
  final double minDistance; // jarak minimal antar sample agar hemat
  final double thickness;

  final List<Offset> _points = <Offset>[];

  TailEffect({
    required this.target,
    required Color color,
    this.maxPoints = 28,
    this.minDistance = 4.0,
    this.thickness = 3.0,
  }) : _color = color {
    priority = -5; // di belakang player
    position = Vector2.zero();
    size = Vector2.zero();
  }

  void setColor(Color next) {
    _color = next;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    size = size;
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Tambah titik baru bila jarak cukup dari titik terakhir
    final current = Offset(target.position.x, target.position.y);
    if (_points.isEmpty) {
      _points.add(current);
    } else {
      final last = _points.last;
      final dx = current.dx - last.dx;
      final dy = current.dy - last.dy;
      final dist2 = dx * dx + dy * dy;
      if (dist2 >= minDistance * minDistance) {
        _points.add(current);
        if (_points.length > maxPoints) {
          _points.removeAt(0);
        }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (_points.length < 2) return;

    // Gambar segmen dengan alpha bertingkat
    final int n = _points.length;
    for (int i = 0; i < n - 1; i++) {
      final t = i / (n - 1); // 0..1, makin kecil = lebih tua
      // Alpha lebih rendah untuk titik lama
      final double alpha = 0.15 + 0.65 * (1.0 - t);
      final paint =
          Paint()
            ..color = _color.withValues(alpha: alpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = thickness;
      final p0 = _points[i];
      final p1 = _points[i + 1];
      canvas.drawLine(p0, p1, paint);
    }
  }
}
