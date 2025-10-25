import 'package:flutter/material.dart';
import 'dart:math' as math;

/// [CustomPaintTheme] menyediakan tema visual berbasis CustomPaint untuk UI elements.
///
/// Sistem ini memungkinkan pembuatan background, button, dan panel dengan
/// efek visual yang sophisticated menggunakan CustomPaint rendering.
///
/// Contoh penggunaan:
/// ```dart
/// CustomPaintTheme.neon.renderButton(canvas, size, isPressed: true);
/// ```
enum CustomPaintTheme {
  /// Tema geometric dengan bentuk clean dan gradient halus
  geometric,
  
  /// Tema crystal dengan efek faceted dan highlight
  crystal,
  
  /// Tema neon dengan glow dan outline terang
  neon,
  
  /// Tema cosmic dengan stars dan nebula effects
  cosmic;
  
  /// Mendapatkan renderer untuk tema ini
  CustomPaintThemeRenderer get renderer {
    switch (this) {
      case CustomPaintTheme.geometric:
        return GeometricThemeRenderer();
      case CustomPaintTheme.crystal:
        return CrystalThemeRenderer();
      case CustomPaintTheme.neon:
        return NeonThemeRenderer();
      case CustomPaintTheme.cosmic:
        return CosmicThemeRenderer();
    }
  }
}

/// [CustomPaintThemeRenderer] adalah base class untuk theme renderers.
///
/// Setiap renderer bertanggung jawab untuk menggambar berbagai UI elements
/// dengan gaya visual yang konsisten sesuai tema.
abstract class CustomPaintThemeRenderer {
  /// Menggambar background untuk panel atau dialog
  void renderBackground(Canvas canvas, Size size, {Color? baseColor});
  
  /// Menggambar button dengan state (normal, pressed, disabled)
  void renderButton(Canvas canvas, Size size, {
    required Color color,
    bool isPressed = false,
    bool isDisabled = false,
  });
  
  /// Menggambar panel dengan border dan shadow
  void renderPanel(Canvas canvas, Size size, {
    required Color backgroundColor,
    bool elevated = true,
  });
  
  /// Menggambar progress bar atau slider
  void renderProgressBar(Canvas canvas, Size size, {
    required double progress,
    required Color fillColor,
    Color? backgroundColor,
  });
}

/// [GeometricThemeRenderer] menggunakan bentuk geometris clean dengan gradient.
///
/// Fokus pada kesederhanaan dan keterbacaan dengan penggunaan bentuk
/// dasar seperti rectangle, circle, dan polygon dengan rounded corners.
class GeometricThemeRenderer extends CustomPaintThemeRenderer {
  @override
  void renderBackground(Canvas canvas, Size size, {Color? baseColor}) {
    final color = baseColor ?? const Color(0xFF2A2A2A);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Background dengan subtle gradient
    final backgroundPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.95),
          color.withValues(alpha: 0.85),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, backgroundPaint);
    
    // Subtle border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderButton(Canvas canvas, Size size, {
    required Color color,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    Color buttonColor = color;
    if (isDisabled) {
      buttonColor = color.withValues(alpha: 0.3);
    } else if (isPressed) {
      buttonColor = Color.lerp(color, Colors.black, 0.2)!;
    }
    
    // Button background
    final buttonPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          buttonColor,
          buttonColor.withValues(alpha: 0.8),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect);
    
    canvas.drawRRect(rrect, buttonPaint);
    
    // Button border
    final borderColor = isPressed 
        ? Colors.white.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.2);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
    
    // Highlight untuk pressed state
    if (isPressed) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.1);
      canvas.drawRRect(rrect, highlightPaint);
    }
  }
  
  @override
  void renderPanel(Canvas canvas, Size size, {
    required Color backgroundColor,
    bool elevated = true,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    
    // Shadow untuk elevated panel
    if (elevated) {
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(
        rrect.shift(const Offset(0, 4)),
        shadowPaint,
      );
    }
    
    // Panel background
    final panelPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          backgroundColor,
          backgroundColor.withValues(alpha: 0.9),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);
    
    canvas.drawRRect(rrect, panelPaint);
    
    // Panel border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderProgressBar(Canvas canvas, Size size, {
    required double progress,
    required Color fillColor,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.grey.withValues(alpha: 0.3);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    
    // Background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);
    
    // Progress fill
    if (progress > 0) {
      final fillWidth = size.width * progress.clamp(0.0, 1.0);
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(size.height / 2));
      
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [fillColor, fillColor.withValues(alpha: 0.8)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(fillRect);
      
      canvas.drawRRect(fillRRect, fillPaint);
    }
  }
}

/// [CrystalThemeRenderer] menggunakan efek kristal dengan faceted surfaces.
///
/// Memberikan kesan premium dengan highlight dan shadow yang kompleks
/// untuk simulasi permukaan kristal yang memantulkan cahaya.
class CrystalThemeRenderer extends CustomPaintThemeRenderer {
  @override
  void renderBackground(Canvas canvas, Size size, {Color? baseColor}) {
    final color = baseColor ?? const Color(0xFF1A1A2E);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Crystal background dengan multiple facets
    _drawCrystalFacets(canvas, size, color);
    
    // Overlay dengan subtle pattern
    final overlayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    canvas.drawRRect(rrect, overlayPaint);
  }
  
  @override
  void renderButton(Canvas canvas, Size size, {
    required Color color,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    Color buttonColor = color;
    if (isDisabled) {
      buttonColor = color.withValues(alpha: 0.3);
    } else if (isPressed) {
      buttonColor = Color.lerp(color, Colors.white, 0.1)!;
    }
    
    // Crystal button dengan faceted effect
    _drawCrystalButton(canvas, size, buttonColor, isPressed);
    
    // Crystal highlights
    if (!isDisabled) {
      _drawCrystalHighlights(canvas, size, buttonColor, isPressed);
    }
  }
  
  @override
  void renderPanel(Canvas canvas, Size size, {
    required Color backgroundColor,
    bool elevated = true,
  }) {
    // Crystal panel dengan depth effect
    _drawCrystalPanel(canvas, size, backgroundColor, elevated);
  }
  
  @override
  void renderProgressBar(Canvas canvas, Size size, {
    required double progress,
    required Color fillColor,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.grey.withValues(alpha: 0.2);
    
    // Crystal progress bar background
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [bgColor, bgColor.withValues(alpha: 0.5)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(rrect, bgPaint);
    
    // Crystal progress fill
    if (progress > 0) {
      final fillWidth = size.width * progress.clamp(0.0, 1.0);
      _drawCrystalProgressFill(canvas, Size(fillWidth, size.height), fillColor);
    }
  }
  
  void _drawCrystalFacets(Canvas canvas, Size size, Color baseColor) {
    final lightColor = Color.lerp(baseColor, Colors.white, 0.3)!;
    final darkColor = Color.lerp(baseColor, Colors.black, 0.2)!;
    
    // Top facet
    final topPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.2, size.height * 0.3)
      ..close();
    
    final topPaint = Paint()
      ..shader = LinearGradient(
        colors: [lightColor, baseColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(topPath.getBounds());
    canvas.drawPath(topPath, topPaint);
    
    // Bottom facet
    final bottomPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    final bottomPaint = Paint()
      ..shader = LinearGradient(
        colors: [baseColor, darkColor],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(bottomPath.getBounds());
    canvas.drawPath(bottomPath, bottomPaint);
  }
  
  void _drawCrystalButton(Canvas canvas, Size size, Color color, bool isPressed) {
    final lightColor = Color.lerp(color, Colors.white, 0.4)!;
    final darkColor = Color.lerp(color, Colors.black, 0.3)!;
    
    // Button facets
    final topFacet = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.9, size.height * 0.4)
      ..lineTo(size.width * 0.1, size.height * 0.4)
      ..close();
    
    final topPaint = Paint()
      ..color = isPressed ? color : lightColor;
    canvas.drawPath(topFacet, topPaint);
    
    final bottomFacet = Path()
      ..moveTo(size.width * 0.1, size.height * 0.6)
      ..lineTo(size.width * 0.9, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    
    final bottomPaint = Paint()
      ..color = isPressed ? lightColor : darkColor;
    canvas.drawPath(bottomFacet, bottomPaint);
  }
  
  void _drawCrystalHighlights(Canvas canvas, Size size, Color color, bool isPressed) {
    final highlightColor = Color.lerp(color, Colors.white, 0.6)!;
    final highlightPaint = Paint()
      ..color = highlightColor.withValues(alpha: isPressed ? 0.3 : 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Diagonal highlights
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.9, size.height * 0.1),
      highlightPaint,
    );
    
    canvas.drawLine(
      Offset(size.width * 0.1, size.height * 0.1),
      Offset(size.width * 0.1, size.height * 0.9),
      highlightPaint,
    );
  }
  
  void _drawCrystalPanel(Canvas canvas, Size size, Color backgroundColor, bool elevated) {
    // Panel dengan crystal effect
    _drawCrystalFacets(canvas, size, backgroundColor);
    
    if (elevated) {
      // Crystal edge highlights
      final edgePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      
      final rect = Rect.fromLTWH(0, 0, size.width, size.height);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
      canvas.drawRRect(rrect, edgePaint);
    }
  }
  
  void _drawCrystalProgressFill(Canvas canvas, Size size, Color fillColor) {
    final lightColor = Color.lerp(fillColor, Colors.white, 0.4)!;
    final darkColor = Color.lerp(fillColor, Colors.black, 0.2)!;
    
    // Progress dengan crystal facets
    final fillPath = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.9, size.height * 0.5)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..lineTo(size.width * 0.1, size.height * 0.5)
      ..close();
    
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [lightColor, fillColor, darkColor],
        stops: const [0.0, 0.5, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fillPath.getBounds());
    
    canvas.drawPath(fillPath, fillPaint);
  }
}

/// [NeonThemeRenderer] menggunakan efek neon dengan glow dan outline terang.
///
/// Memberikan kesan futuristik dengan penggunaan glow effects,
/// outline terang, dan gradient yang vibrant.
class NeonThemeRenderer extends CustomPaintThemeRenderer {
  @override
  void renderBackground(Canvas canvas, Size size, {Color? baseColor}) {
    final color = baseColor ?? const Color(0xFF0A0A0A);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    
    // Dark background
    final bgPaint = Paint()..color = color;
    canvas.drawRRect(rrect, bgPaint);
    
    // Neon border glow
    final glowPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawRRect(rrect, glowPaint);
    
    // Neon border
    final borderPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderButton(Canvas canvas, Size size, {
    required Color color,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    Color neonColor = color;
    if (isDisabled) {
      neonColor = Colors.grey;
    } else if (isPressed) {
      neonColor = Color.lerp(color, Colors.white, 0.2)!;
    }
    
    // Button background (dark)
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8);
    canvas.drawRRect(rrect, bgPaint);
    
    // Neon glow
    if (!isDisabled) {
      final glowPaint = Paint()
        ..color = neonColor.withValues(alpha: isPressed ? 0.6 : 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isPressed ? 4.0 : 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rrect, glowPaint);
    }
    
    // Neon outline
    final outlinePaint = Paint()
      ..color = neonColor.withValues(alpha: isDisabled ? 0.3 : 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, outlinePaint);
    
    // Inner glow untuk pressed state
    if (isPressed && !isDisabled) {
      final innerGlowPaint = Paint()
        ..color = neonColor.withValues(alpha: 0.2);
      canvas.drawRRect(rrect, innerGlowPaint);
    }
  }
  
  @override
  void renderPanel(Canvas canvas, Size size, {
    required Color backgroundColor,
    bool elevated = true,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    
    // Dark panel background
    final bgPaint = Paint()
      ..color = backgroundColor.withValues(alpha: 0.9);
    canvas.drawRRect(rrect, bgPaint);
    
    if (elevated) {
      // Outer glow
      final outerGlowPaint = Paint()
        ..color = Colors.blue.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
      canvas.drawRRect(rrect, outerGlowPaint);
    }
    
    // Neon border
    final borderPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderProgressBar(Canvas canvas, Size size, {
    required double progress,
    required Color fillColor,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.black.withValues(alpha: 0.5);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    
    // Background
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRRect(rrect, bgPaint);
    
    // Background border
    final bgBorderPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, bgBorderPaint);
    
    // Progress fill dengan neon effect
    if (progress > 0) {
      final fillWidth = size.width * progress.clamp(0.0, 1.0);
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(size.height / 2));
      
      // Fill glow
      final glowPaint = Paint()
        ..color = fillColor.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawRRect(fillRRect, glowPaint);
      
      // Fill color
      final fillPaint = Paint()..color = fillColor;
      canvas.drawRRect(fillRRect, fillPaint);
      
      // Fill highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3);
      final highlightRect = Rect.fromLTWH(0, 0, fillWidth, size.height * 0.4);
      final highlightRRect = RRect.fromRectAndRadius(highlightRect, Radius.circular(size.height / 2));
      canvas.drawRRect(highlightRRect, highlightPaint);
    }
  }
}

/// [CosmicThemeRenderer] menggunakan efek cosmic dengan stars dan nebula.
///
/// Memberikan kesan mystical dengan gradient kompleks, particle effects,
/// dan animasi yang mengingatkan pada objek-objek kosmik.
class CosmicThemeRenderer extends CustomPaintThemeRenderer {
  @override
  void renderBackground(Canvas canvas, Size size, {Color? baseColor}) {
    final color = baseColor ?? const Color(0xFF0D0D1A);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(12));
    
    // Cosmic background dengan nebula effect
    final nebulaPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 1.0),
          Color.lerp(color, Colors.purple, 0.3)!.withValues(alpha: 0.8),
          Color.lerp(color, Colors.blue, 0.2)!.withValues(alpha: 0.6),
          color.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        center: const Alignment(0.3, -0.3),
      ).createShader(rect);
    
    canvas.drawRRect(rrect, nebulaPaint);
    
    // Stars
    _drawStars(canvas, size);
    
    // Cosmic border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderButton(Canvas canvas, Size size, {
    required Color color,
    bool isPressed = false,
    bool isDisabled = false,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    Color cosmicColor = color;
    if (isDisabled) {
      cosmicColor = Colors.grey.withValues(alpha: 0.5);
    } else if (isPressed) {
      cosmicColor = Color.lerp(color, Colors.white, 0.1)!;
    }
    
    // Button cosmic background
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          cosmicColor.withValues(alpha: 0.8),
          cosmicColor.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    
    canvas.drawRRect(rrect, bgPaint);
    
    // Cosmic particles
    if (!isDisabled) {
      _drawCosmicParticles(canvas, size, cosmicColor, isPressed);
    }
    
    // Button border
    final borderPaint = Paint()
      ..color = cosmicColor.withValues(alpha: isDisabled ? 0.3 : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderPanel(Canvas canvas, Size size, {
    required Color backgroundColor,
    bool elevated = true,
  }) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(16));
    
    // Cosmic panel background
    final panelPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          backgroundColor,
          Color.lerp(backgroundColor, Colors.purple, 0.2)!,
          backgroundColor.withValues(alpha: 0.9),
        ],
        stops: const [0.0, 0.5, 1.0],
        center: const Alignment(-0.3, -0.3),
      ).createShader(rect);
    
    canvas.drawRRect(rrect, panelPaint);
    
    // Stars dalam panel
    _drawStars(canvas, size, density: 0.3);
    
    if (elevated) {
      // Cosmic glow
      final glowPaint = Paint()
        ..color = Colors.purple.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawRRect(rrect, glowPaint);
    }
    
    // Panel border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);
  }
  
  @override
  void renderProgressBar(Canvas canvas, Size size, {
    required double progress,
    required Color fillColor,
    Color? backgroundColor,
  }) {
    final bgColor = backgroundColor ?? Colors.black.withValues(alpha: 0.6);
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(size.height / 2));
    
    // Background dengan cosmic effect
    final bgPaint = Paint()
      ..shader = LinearGradient(
        colors: [bgColor, bgColor.withValues(alpha: 0.8)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(rect);
    canvas.drawRRect(rrect, bgPaint);
    
    // Progress fill dengan cosmic effect
    if (progress > 0) {
      final fillWidth = size.width * progress.clamp(0.0, 1.0);
      final fillRect = Rect.fromLTWH(0, 0, fillWidth, size.height);
      final fillRRect = RRect.fromRectAndRadius(fillRect, Radius.circular(size.height / 2));
      
      // Cosmic fill
      final fillPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            fillColor,
            Color.lerp(fillColor, Colors.white, 0.3)!,
            fillColor,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(fillRect);
      
      canvas.drawRRect(fillRRect, fillPaint);
      
      // Cosmic particles dalam progress
      _drawCosmicParticles(canvas, Size(fillWidth, size.height), fillColor, false);
    }
  }
  
  void _drawStars(Canvas canvas, Size size, {double density = 1.0}) {
    final starPaint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final random = math.Random(42); // Fixed seed untuk konsistensi
    
    final starCount = (20 * density).round();
    for (int i = 0; i < starCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 1.5 + 0.5;
      
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }
  
  void _drawCosmicParticles(Canvas canvas, Size size, Color color, bool enhanced) {
    final particlePaint = Paint()..color = color.withValues(alpha: 0.6);
    final random = math.Random(123); // Fixed seed
    
    final particleCount = enhanced ? 8 : 5;
    for (int i = 0; i < particleCount; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 2 + 1;
      
      // Particle dengan glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(Offset(x, y), radius * 2, glowPaint);
      
      canvas.drawCircle(Offset(x, y), radius, particlePaint);
    }
  }
}

/// Widget helper untuk menggunakan CustomPaint themes
class ThemedCustomPaint extends StatelessWidget {
  final CustomPaintTheme theme;
  final Size size;
  final Widget? child;
  final Color? baseColor;
  
  const ThemedCustomPaint({
    super.key,
    required this.theme,
    required this.size,
    this.child,
    this.baseColor,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _ThemedBackgroundPainter(theme.renderer, baseColor),
      child: child,
    );
  }
}

class _ThemedBackgroundPainter extends CustomPainter {
  final CustomPaintThemeRenderer renderer;
  final Color? baseColor;
  
  _ThemedBackgroundPainter(this.renderer, this.baseColor);
  
  @override
  void paint(Canvas canvas, Size size) {
    renderer.renderBackground(canvas, size, baseColor: baseColor);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}