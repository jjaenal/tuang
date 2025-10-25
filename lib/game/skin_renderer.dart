import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../models/skin_type.dart';

/// [SkinRenderer] adalah abstraksi untuk menggambar tampilan (skin) karakter.
///
/// Setiap renderer bertanggung jawab menggambar bentuk, warna, dan efek visual
/// pada `Canvas` berdasarkan ukuran komponen dan status boost. Kelas ini juga
/// menyediakan `factory` untuk memilih renderer yang sesuai dari [SkinType].
///
/// Penggunaan umum:
/// ```dart
/// final renderer = SkinRenderer.create(SkinType.basic, Colors.red);
/// renderer.render(canvas, size, isBoost: true);
/// ```
abstract class SkinRenderer {
  /// Warna utama skin
  final Color color;

  /// Konstruktor
  SkinRenderer(this.color);

  /// Menggambar skin ke `canvas` dengan ukuran komponen [size].
  ///
  /// Jika [isBoost] bernilai true, renderer dapat menampilkan efek visual
  /// tambahan (mis. glow atau opacity berbeda) untuk menandai status boost.
  void render(Canvas canvas, Vector2 size, {bool isBoost = false});

  /// Factory untuk membuat renderer berdasarkan [SkinType].
  static SkinRenderer create(SkinType type, Color color) {
    switch (type) {
      case SkinType.basic:
        return BasicSkinRenderer(color);
      case SkinType.advanced:
        return AdvancedSkinRenderer(color);
      case SkinType.premium:
        return PremiumSkinRenderer(color);
      case SkinType.legendary:
        return LegendarySkinRenderer(color);
    }
  }
}

/// [BasicSkinRenderer] menggambar bentuk dasar dengan detail minimal.
///
/// Fokus pada bentuk tubuh sederhana, mata, dan paruh dengan sedikit gradient.
/// Cocok untuk performa tinggi dan tampilan yang bersih.
class BasicSkinRenderer extends SkinRenderer {
  BasicSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final bodyColor = isBoost ? color.withOpacity(0.8) : color;

    // Gambar bentuk dasar (persegi panjang dengan sudut membulat)
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.x,
      height: size.y,
    );
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(8),
    );

    // Tambahkan gradient untuk body
    final bodyPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [bodyColor, bodyColor.withOpacity(0.7)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bodyRect);

    canvas.drawRRect(bodyRRect, bodyPaint);

    // Mata dengan pupil
    final eyeOuterPaint = Paint()..color = Colors.white;
    final eyePupilPaint = Paint()..color = Colors.black;
    final eyeCenter = Offset(size.x * 0.2, -size.y * 0.15);

    // Mata luar (putih)
    canvas.drawCircle(eyeCenter, size.x * 0.1, eyeOuterPaint);

    // Pupil (hitam)
    canvas.drawCircle(eyeCenter, size.x * 0.05, eyePupilPaint);

    // Highlight pada mata
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(eyeCenter.dx - size.x * 0.02, eyeCenter.dy - size.y * 0.02),
      size.x * 0.02,
      highlightPaint,
    );

    // Tambahkan paruh sederhana
    final beakPaint = Paint()..color = Colors.orange.shade300;
    final beakPath =
        Path()
          ..moveTo(size.x * 0.4, 0)
          ..lineTo(size.x * 0.55, -size.y * 0.05)
          ..lineTo(size.x * 0.55, size.y * 0.05)
          ..close();
    canvas.drawPath(beakPath, beakPaint);
    canvas.restore();
  }
}

/// [AdvancedSkinRenderer] menambahkan detail lebih kaya seperti sayap dan pola.
///
/// Menggunakan gradient yang lebih kompleks dan dekorasi tambahan untuk
/// memberikan tampilan lebih premium dibanding basic.
class AdvancedSkinRenderer extends SkinRenderer {
  AdvancedSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final bodyColor = isBoost ? color.withOpacity(0.8) : color;

    // Gambar bentuk dasar (persegi panjang dengan sudut membulat)
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.x,
      height: size.y,
    );
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(10),
    );

    // Gradient untuk body
    final bodyPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [bodyColor.withOpacity(1.0), bodyColor.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bodyRect);
    canvas.drawRRect(bodyRRect, bodyPaint);

    // Sayap (wing) - bentuk lebih menarik
    final wingPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [bodyColor.withOpacity(0.8), bodyColor.withOpacity(0.4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              -size.x * 0.4,
              -size.y * 0.2,
              size.x * 0.3,
              size.y * 0.4,
            ),
          );

    final wingPath =
        Path()
          ..moveTo(-size.x * 0.1, -size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.25,
            -size.y * 0.2,
            -size.x * 0.4,
            -size.y * 0.1,
          )
          ..lineTo(-size.x * 0.35, size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.2,
            size.y * 0.2,
            -size.x * 0.1,
            size.y * 0.1,
          )
          ..close();
    canvas.drawPath(wingPath, wingPaint);

    // Mata dengan detail
    final eyeOuterPaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final eyeCenter = Offset(size.x * 0.2, -size.y * 0.15);

    // Mata luar (putih)
    canvas.drawCircle(eyeCenter, size.x * 0.1, eyeOuterPaint);

    // Pupil (hitam)
    canvas.drawCircle(eyeCenter, size.x * 0.05, pupilPaint);

    // Highlight pada mata
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(eyeCenter.dx - size.x * 0.02, eyeCenter.dy - size.y * 0.02),
      size.x * 0.02,
      highlightPaint,
    );

    // Paruh (beak) dengan gradient
    final beakPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.orange.shade300, Colors.orange.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              size.x * 0.4,
              -size.y * 0.1,
              size.x * 0.2,
              size.y * 0.2,
            ),
          );

    final beakPath =
        Path()
          ..moveTo(size.x * 0.4, 0)
          ..lineTo(size.x * 0.6, -size.y * 0.08)
          ..lineTo(size.x * 0.6, size.y * 0.08)
          ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Pola dekoratif pada badan
    final patternPaint =
        Paint()
          ..color = bodyColor.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Garis melengkung pada badan
    final patternPath =
        Path()
          ..moveTo(0, -size.y * 0.2)
          ..quadraticBezierTo(size.x * 0.1, 0, 0, size.y * 0.2);
    canvas.drawPath(patternPath, patternPaint);

    // Pastikan state canvas dipulihkan agar tidak mismatch
    canvas.restore();
  }
}

/// Renderer untuk skin premium
/// [PremiumSkinRenderer] menghadirkan efek glow halus dan komposisi sayap kompleks.
///
/// Memberikan rasa mewah melalui penggunaan gradient multi-stop dan dekorasi
/// pola yang lebih hidup.
class PremiumSkinRenderer extends SkinRenderer {
  PremiumSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final bodyColor = isBoost ? color.withOpacity(0.8) : color;

    // Efek glow di belakang (lebih halus dari legendary)
    final glowPaint =
        Paint()
          ..color = bodyColor.withOpacity(0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawCircle(Offset.zero, size.x * 0.6, glowPaint);

    // Gambar bentuk dasar (persegi panjang dengan sudut membulat)
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.x,
      height: size.y,
    );
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(12),
    );

    // Efek gradien pada badan
    final gradientPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              bodyColor.withOpacity(1.0),
              bodyColor.withOpacity(0.7),
              bodyColor.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bodyRect);

    canvas.drawRRect(bodyRRect, gradientPaint);

    // Sayap (wing) - bentuk lebih kompleks
    final wingPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [bodyColor.withOpacity(0.9), bodyColor.withOpacity(0.5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              -size.x * 0.5,
              -size.y * 0.3,
              size.x * 0.4,
              size.y * 0.6,
            ),
          );

    // Sayap atas
    final topWingPath =
        Path()
          ..moveTo(-size.x * 0.1, -size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.3,
            -size.y * 0.3,
            -size.x * 0.45,
            -size.y * 0.2,
          )
          ..lineTo(-size.x * 0.3, -size.y * 0.05)
          ..close();

    // Sayap bawah
    final bottomWingPath =
        Path()
          ..moveTo(-size.x * 0.1, size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.3,
            size.y * 0.3,
            -size.x * 0.45,
            size.y * 0.2,
          )
          ..lineTo(-size.x * 0.3, size.y * 0.05)
          ..close();

    canvas.drawPath(topWingPath, wingPaint);
    canvas.drawPath(bottomWingPath, wingPaint);

    // Paruh (beak) dengan gradient
    final beakPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.orange.shade300, Colors.deepOrange],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              size.x * 0.4,
              -size.y * 0.1,
              size.x * 0.2,
              size.y * 0.2,
            ),
          );

    final beakPath =
        Path()
          ..moveTo(size.x * 0.4, 0)
          ..lineTo(size.x * 0.6, -size.y * 0.08)
          ..lineTo(size.x * 0.6, size.y * 0.08)
          ..close();
    canvas.drawPath(beakPath, beakPaint);

    // Mata dengan detail
    final eyeOuterPaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    final eyeCenter = Offset(size.x * 0.2, -size.y * 0.15);

    // Mata luar (putih)
    canvas.drawCircle(eyeCenter, size.x * 0.1, eyeOuterPaint);

    // Pupil (hitam)
    canvas.drawCircle(eyeCenter, size.x * 0.05, pupilPaint);

    // Highlight pada mata
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(eyeCenter.dx - size.x * 0.02, eyeCenter.dy - size.y * 0.02),
      size.x * 0.02,
      highlightPaint,
    );

    // Pola dekoratif pada badan
    final patternPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    // Garis melengkung pada badan
    final patternPath =
        Path()
          ..moveTo(-size.x * 0.1, -size.y * 0.2)
          ..quadraticBezierTo(size.x * 0.1, 0, -size.x * 0.1, size.y * 0.2);
    canvas.drawPath(patternPath, patternPaint);

    // Tambahkan pola kedua
    final patternPath2 =
        Path()
          ..moveTo(size.x * 0.1, -size.y * 0.2)
          ..quadraticBezierTo(size.x * 0.3, 0, size.x * 0.1, size.y * 0.2);
    canvas.drawPath(patternPath2, patternPaint);
    canvas.restore();
  }
}

/// Renderer untuk skin legendaris
/// [LegendarySkinRenderer] adalah tingkat tertinggi dengan efek glow kuat,
/// mahkota, dan sayap berlapis.
///
/// Menonjolkan karakter dengan visual paling kaya dan dramatis di antara semua
/// skin renderer.
class LegendarySkinRenderer extends SkinRenderer {
  LegendarySkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    final bodyColor = isBoost ? color.withOpacity(0.8) : color;

    // Efek glow di belakang
    final glowPaint =
        Paint()
          ..color = bodyColor.withOpacity(0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset.zero, size.x * 0.7, glowPaint);

    // Gambar bentuk dasar (persegi panjang dengan sudut membulat)
    final bodyRect = Rect.fromCenter(
      center: const Offset(0, 0),
      width: size.x,
      height: size.y,
    );
    final bodyRRect = RRect.fromRectAndRadius(
      bodyRect,
      const Radius.circular(8),
    );

    // Efek gradien pada badan
    final gradientPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              bodyColor.withOpacity(1.0),
              bodyColor.withOpacity(0.7),
              bodyColor.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
            center: Alignment.center,
            radius: 1.0,
          ).createShader(bodyRect);

    canvas.drawRRect(bodyRRect, gradientPaint);

    // Sayap (wing) - bentuk lebih kompleks
    final wingPaint =
        Paint()
          ..color = bodyColor.withOpacity(0.6)
          ..style = PaintingStyle.fill;

    // Sayap atas
    final topWingPath =
        Path()
          ..moveTo(-size.x * 0.1, -size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.3,
            -size.y * 0.4,
            -size.x * 0.5,
            -size.y * 0.3,
          )
          ..lineTo(-size.x * 0.3, -size.y * 0.1)
          ..close();

    // Sayap bawah
    final bottomWingPath =
        Path()
          ..moveTo(-size.x * 0.1, size.y * 0.1)
          ..quadraticBezierTo(
            -size.x * 0.3,
            size.y * 0.4,
            -size.x * 0.5,
            size.y * 0.3,
          )
          ..lineTo(-size.x * 0.3, size.y * 0.1)
          ..close();

    canvas.drawPath(topWingPath, wingPaint);
    canvas.drawPath(bottomWingPath, wingPaint);

    // Paruh (beak) - bentuk lebih kompleks
    final beakPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(
              size.x * 0.4,
              -size.y * 0.1,
              size.x * 0.2,
              size.y * 0.2,
            ),
          );

    final beakPath =
        Path()
          ..moveTo(size.x * 0.4, 0)
          ..lineTo(size.x * 0.6, -size.y * 0.08)
          ..lineTo(size.x * 0.6, size.y * 0.08)
          ..close();

    canvas.drawPath(beakPath, beakPaint);

    // Mata - dengan efek glow
    final eyeGlowPaint =
        Paint()
          ..color = Colors.white.withOpacity(0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    final eyeCenter = Offset(size.x * 0.2, -size.y * 0.15);
    canvas.drawCircle(eyeCenter, size.x * 0.1, eyeGlowPaint);

    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    canvas.drawCircle(eyeCenter, size.x * 0.08, eyePaint);
    canvas.drawCircle(eyeCenter, size.x * 0.04, pupilPaint);

    // Highlight pada mata
    final highlightPaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(eyeCenter.dx - size.x * 0.02, eyeCenter.dy - size.y * 0.02),
      size.x * 0.02,
      highlightPaint,
    );

    // Mahkota kecil di atas kepala
    final crownPaint = Paint()..color = Colors.amber;
    final crownPath =
        Path()
          ..moveTo(0, -size.y * 0.5)
          ..lineTo(size.x * 0.1, -size.y * 0.4)
          ..lineTo(0, -size.y * 0.35)
          ..lineTo(-size.x * 0.1, -size.y * 0.4)
          ..close();

    canvas.drawPath(crownPath, crownPaint);
    canvas.restore();
  }
}
