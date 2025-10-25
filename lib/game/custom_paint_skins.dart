import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'dart:math' as math;
import 'skin_renderer.dart';

/// [CustomPaintSkinRenderer] menggunakan CustomPaint untuk rendering yang lebih sophisticated.
///
/// Sistem ini memberikan kontrol penuh atas rendering dengan path, gradient kompleks,
/// dan efek visual yang lebih advanced dibanding Canvas rendering biasa.
///
/// Contoh penggunaan:
/// ```dart
/// final renderer = CustomPaintSkinRenderer.create(SkinType.legendary, Colors.blue);
/// renderer.render(canvas, size, isBoost: true);
/// ```

/// [GeometricSkinRenderer] menggunakan bentuk geometris dengan gradient halus.
///
/// Fokus pada bentuk clean dengan kombinasi lingkaran, segitiga, dan persegi
/// yang memberikan kesan modern dan minimalis.
class GeometricSkinRenderer extends SkinRenderer {
  GeometricSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    final bodyColor = isBoost ? color.withValues(alpha: 0.9) : color;
    final accentColor = Color.lerp(bodyColor, Colors.white, 0.3)!;
    
    // Body utama - hexagon dengan gradient radial
    final hexPath = _createHexagonPath(size.x * 0.4);
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        colors: [accentColor, bodyColor, bodyColor.withValues(alpha: 0.8)],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.x * 0.4));
    
    canvas.drawPath(hexPath, bodyPaint);
    
    // Border hexagon
    final borderPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(hexPath, borderPaint);
    
    // Core center - lingkaran kecil dengan glow
    if (isBoost) {
      final glowPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset.zero, size.x * 0.15, glowPaint);
    }
    
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [Colors.white, accentColor],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: size.x * 0.1));
    canvas.drawCircle(Offset.zero, size.x * 0.1, corePaint);
    
    // Accent triangles di sudut
    _drawAccentTriangles(canvas, size, accentColor);
    
    canvas.restore();
  }
  
  Path _createHexagonPath(double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x = radius * cos(angle);
      final y = radius * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }
  
  void _drawAccentTriangles(Canvas canvas, Vector2 size, Color accentColor) {
    final trianglePaint = Paint()..color = accentColor.withValues(alpha: 0.4);
    final triangleSize = size.x * 0.08;
    
    // Top triangle
    final topTriangle = Path()
      ..moveTo(0, -size.y * 0.35)
      ..lineTo(-triangleSize, -size.y * 0.25)
      ..lineTo(triangleSize, -size.y * 0.25)
      ..close();
    canvas.drawPath(topTriangle, trianglePaint);
    
    // Bottom triangle
    final bottomTriangle = Path()
      ..moveTo(0, size.y * 0.35)
      ..lineTo(-triangleSize, size.y * 0.25)
      ..lineTo(triangleSize, size.y * 0.25)
      ..close();
    canvas.drawPath(bottomTriangle, trianglePaint);
  }
}

/// [CrystalSkinRenderer] menciptakan efek kristal dengan faceted surfaces.
///
/// Menggunakan multiple gradient dan highlight untuk simulasi permukaan kristal
/// yang memantulkan cahaya dari berbagai sudut.
class CrystalSkinRenderer extends SkinRenderer {
  CrystalSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    final baseColor = isBoost ? color.withValues(alpha: 0.95) : color;
    final lightColor = Color.lerp(baseColor, Colors.white, 0.6)!;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.3)!;
    
    // Crystal body - diamond shape dengan multiple facets
    _drawCrystalFacets(canvas, size, baseColor, lightColor, darkColor);
    
    // Inner glow untuk boost effect
    if (isBoost) {
      final glowPaint = Paint()
        ..color = lightColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawCircle(Offset.zero, size.x * 0.3, glowPaint);
    }
    
    // Crystal highlights - garis-garis tipis yang berkilau
    _drawCrystalHighlights(canvas, size, lightColor);
    
    canvas.restore();
  }
  
  void _drawCrystalFacets(Canvas canvas, Vector2 size, Color baseColor, Color lightColor, Color darkColor) {
    final radius = size.x * 0.4;
    
    // Top facet
    final topFacet = Path()
      ..moveTo(0, -radius)
      ..lineTo(-radius * 0.6, -radius * 0.3)
      ..lineTo(0, 0)
      ..lineTo(radius * 0.6, -radius * 0.3)
      ..close();
    
    final topPaint = Paint()
      ..shader = LinearGradient(
        colors: [lightColor, baseColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(topFacet.getBounds());
    canvas.drawPath(topFacet, topPaint);
    
    // Left facet
    final leftFacet = Path()
      ..moveTo(-radius * 0.6, -radius * 0.3)
      ..lineTo(-radius, 0)
      ..lineTo(0, radius)
      ..lineTo(0, 0)
      ..close();
    
    final leftPaint = Paint()
      ..shader = LinearGradient(
        colors: [darkColor, baseColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(leftFacet.getBounds());
    canvas.drawPath(leftFacet, leftPaint);
    
    // Right facet
    final rightFacet = Path()
      ..moveTo(radius * 0.6, -radius * 0.3)
      ..lineTo(radius, 0)
      ..lineTo(0, radius)
      ..lineTo(0, 0)
      ..close();
    
    final rightPaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor, lightColor],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rightFacet.getBounds());
    canvas.drawPath(rightFacet, rightPaint);
  }
  
  void _drawCrystalHighlights(Canvas canvas, Vector2 size, Color lightColor) {
    final highlightPaint = Paint()
      ..color = lightColor.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Vertical highlight
    canvas.drawLine(
      Offset(0, -size.y * 0.4),
      Offset(0, size.y * 0.4),
      highlightPaint,
    );
    
    // Diagonal highlights
    canvas.drawLine(
      Offset(-size.x * 0.3, -size.y * 0.2),
      Offset(size.x * 0.3, size.y * 0.2),
      highlightPaint,
    );
    
    canvas.drawLine(
      Offset(size.x * 0.3, -size.y * 0.2),
      Offset(-size.x * 0.3, size.y * 0.2),
      highlightPaint,
    );
  }
}

/// [NeonSkinRenderer] menciptakan efek neon dengan glow dan outline terang.
///
/// Menggunakan multiple blur layers dan gradient untuk simulasi cahaya neon
/// yang memancar dari bentuk geometris.
class NeonSkinRenderer extends SkinRenderer {
  NeonSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    final neonColor = isBoost ? color.withValues(alpha: 1.0) : color;
    final glowColor = Color.lerp(neonColor, Colors.white, 0.3)!;
    
    // Outer glow - multiple layers untuk efek neon
    _drawNeonGlow(canvas, size, neonColor, glowColor, isBoost);
    
    // Main neon shape - rounded rectangle dengan outline terang
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: size.x * 0.7, height: size.y * 0.7),
      Radius.circular(size.x * 0.15),
    );
    
    // Inner fill dengan gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          glowColor.withValues(alpha: 0.3),
          neonColor.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, fillPaint);
    
    // Neon outline
    final outlinePaint = Paint()
      ..color = glowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawRRect(bodyRect, outlinePaint);
    
    // Inner details - circuit-like patterns
    _drawNeonCircuits(canvas, size, glowColor);
    
    canvas.restore();
  }
  
  void _drawNeonGlow(Canvas canvas, Vector2 size, Color neonColor, Color glowColor, bool isBoost) {
    final glowRadius = size.x * (isBoost ? 0.5 : 0.4);
    
    // Outer glow
    final outerGlowPaint = Paint()
      ..color = neonColor.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset.zero, glowRadius, outerGlowPaint);
    
    // Middle glow
    final middleGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawCircle(Offset.zero, glowRadius * 0.7, middleGlowPaint);
    
    // Inner glow
    final innerGlowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(Offset.zero, glowRadius * 0.4, innerGlowPaint);
  }
  
  void _drawNeonCircuits(Canvas canvas, Vector2 size, Color glowColor) {
    final circuitPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    // Horizontal lines
    canvas.drawLine(
      Offset(-size.x * 0.25, -size.y * 0.1),
      Offset(size.x * 0.25, -size.y * 0.1),
      circuitPaint,
    );
    
    canvas.drawLine(
      Offset(-size.x * 0.25, size.y * 0.1),
      Offset(size.x * 0.25, size.y * 0.1),
      circuitPaint,
    );
    
    // Vertical connector
    canvas.drawLine(
      Offset(0, -size.y * 0.1),
      Offset(0, size.y * 0.1),
      circuitPaint,
    );
    
    // Corner dots
    final dotPaint = Paint()..color = glowColor;
    canvas.drawCircle(Offset(-size.x * 0.2, -size.y * 0.1), 2, dotPaint);
    canvas.drawCircle(Offset(size.x * 0.2, -size.y * 0.1), 2, dotPaint);
    canvas.drawCircle(Offset(-size.x * 0.2, size.y * 0.1), 2, dotPaint);
    canvas.drawCircle(Offset(size.x * 0.2, size.y * 0.1), 2, dotPaint);
  }
}

/// [CosmicSkinRenderer] menciptakan efek cosmic dengan stars dan nebula.
///
/// Menggunakan particle-like effects, gradient kompleks, dan animasi
/// untuk simulasi objek kosmik dengan bintang dan nebula.
class CosmicSkinRenderer extends SkinRenderer {
  CosmicSkinRenderer(super.color);

  @override
  void render(Canvas canvas, Vector2 size, {bool isBoost = false}) {
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    
    final cosmicColor = isBoost ? color.withValues(alpha: 1.0) : color;
    final starColor = Color.lerp(cosmicColor, Colors.white, 0.7)!;
    final nebulaColor = Color.lerp(cosmicColor, Colors.purple, 0.4)!;
    
    // Nebula background - gradient radial dengan multiple colors
    _drawNebula(canvas, size, cosmicColor, nebulaColor, isBoost);
    
    // Central cosmic body
    _drawCosmicCore(canvas, size, cosmicColor, starColor);
    
    // Orbiting particles/stars
    _drawOrbitingStars(canvas, size, starColor, isBoost);
    
    // Energy rings
    _drawEnergyRings(canvas, size, starColor, isBoost);
    
    canvas.restore();
  }
  
  void _drawNebula(Canvas canvas, Vector2 size, Color cosmicColor, Color nebulaColor, bool isBoost) {
    final nebulaRadius = size.x * (isBoost ? 0.6 : 0.5);
    
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          cosmicColor.withValues(alpha: 0.8),
          nebulaColor.withValues(alpha: 0.4),
          cosmicColor.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: nebulaRadius));
    
    canvas.drawCircle(Offset.zero, nebulaRadius, nebulaPaint);
  }
  
  void _drawCosmicCore(Canvas canvas, Vector2 size, Color cosmicColor, Color starColor) {
    final coreRadius = size.x * 0.2;
    
    // Core dengan gradient radial
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [starColor, cosmicColor, cosmicColor.withValues(alpha: 0.6)],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: coreRadius));
    
    canvas.drawCircle(Offset.zero, coreRadius, corePaint);
    
    // Core highlight
    final highlightPaint = Paint()
      ..color = starColor.withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(Offset.zero, coreRadius * 0.5, highlightPaint);
  }
  
  void _drawOrbitingStars(Canvas canvas, Vector2 size, Color starColor, bool isBoost) {
    final orbitRadius = size.x * 0.35;
    final starCount = isBoost ? 8 : 6;
    
    final starPaint = Paint()..color = starColor;
    
    for (int i = 0; i < starCount; i++) {
      final angle = (i * 360 / starCount) * (3.14159 / 180);
      final x = orbitRadius * cos(angle);
      final y = orbitRadius * sin(angle);
      
      // Star dengan glow
      final glowPaint = Paint()
        ..color = starColor.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(Offset(x, y), 3, glowPaint);
      
      canvas.drawCircle(Offset(x, y), 1.5, starPaint);
    }
  }
  
  void _drawEnergyRings(Canvas canvas, Vector2 size, Color starColor, bool isBoost) {
    final ringPaint = Paint()
      ..color = starColor.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Inner ring
    canvas.drawCircle(Offset.zero, size.x * 0.25, ringPaint);
    
    // Outer ring
    if (isBoost) {
      final outerRingPaint = Paint()
        ..color = starColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      canvas.drawCircle(Offset.zero, size.x * 0.45, outerRingPaint);
    }
  }
}

// Helper functions untuk trigonometri
double cos(double radians) => radians.cos();
double sin(double radians) => radians.sin();

extension on double {
  double cos() => math.cos(this);
  double sin() => math.sin(this);
}