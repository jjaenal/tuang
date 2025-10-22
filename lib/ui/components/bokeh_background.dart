import 'dart:math';
import 'package:flutter/material.dart';

/// Komponen untuk menampilkan efek bokeh (blur circles) pada latar belakang
///
/// Efek bokeh menciptakan lingkaran-lingkaran blur dengan berbagai ukuran dan opacity
/// yang bergerak perlahan untuk memberikan kesan dinamis dan kedalaman pada background
class BokehBackground extends StatefulWidget {
  /// Warna dasar background
  final Color backgroundColor;

  /// Jumlah lingkaran bokeh yang akan ditampilkan
  final int bokehCount;

  /// Kecepatan animasi bokeh (1.0 = normal, 0.5 = setengah kecepatan)
  final double animationSpeed;

  /// Intensitas efek bokeh (0.0 - 1.0)
  final double intensity;

  /// Child widget yang akan ditampilkan di atas background
  final Widget? child;

  const BokehBackground({
    super.key,
    this.backgroundColor = Colors.black,
    this.bokehCount = 15,
    this.animationSpeed = 1.0,
    this.intensity = 0.7,
    this.child,
  });

  @override
  State<BokehBackground> createState() => _BokehBackgroundState();
}

class _BokehBackgroundState extends State<BokehBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<BokehCircle> _bokehCircles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Setup animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 20),
    )..repeat();

    // Generate bokeh circles
    _generateBokehCircles();
  }

  void _generateBokehCircles() {
    _bokehCircles = List.generate(widget.bokehCount, (_) {
      return BokehCircle(
        position: Offset(_random.nextDouble(), _random.nextDouble()),
        size: _random.nextDouble() * 0.2 + 0.05, // 5% - 25% of screen
        color: _getRandomColor(),
        speed: _random.nextDouble() * 0.02 + 0.005, // Movement speed
        direction: _random.nextDouble() * 2 * pi, // Random direction
      );
    });
  }

  Color _getRandomColor() {
    // Warna-warna yang cocok untuk efek bokeh
    final List<Color> bokehColors = [
      Colors.purple.withValues(alpha: 0.3 * widget.intensity),
      Colors.deepPurple.withValues(alpha: 0.3 * widget.intensity),
      Colors.blue.withValues(alpha: 0.3 * widget.intensity),
      Colors.lightBlue.withValues(alpha: 0.25 * widget.intensity),
      Colors.cyan.withValues(alpha: 0.25 * widget.intensity),
    ];

    return bokehColors[_random.nextInt(bokehColors.length)];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update bokeh positions
        for (var bokeh in _bokehCircles) {
          bokeh.updatePosition(_controller.value * widget.animationSpeed);
        }

        return Stack(
          children: [
            // Background color
            Container(color: widget.backgroundColor),

            // Bokeh circles
            CustomPaint(
              painter: BokehPainter(circles: _bokehCircles),
              size: Size.infinite,
            ),

            // Child content
            if (widget.child != null) widget.child!,
          ],
        );
      },
    );
  }
}

/// Data class untuk menyimpan informasi lingkaran bokeh
class BokehCircle {
  /// Posisi relatif (0.0 - 1.0) pada layar
  Offset position;

  /// Ukuran relatif terhadap layar (0.0 - 1.0)
  final double size;

  /// Warna lingkaran
  final Color color;

  /// Kecepatan pergerakan
  final double speed;

  /// Arah pergerakan dalam radian
  final double direction;

  BokehCircle({
    required this.position,
    required this.size,
    required this.color,
    required this.speed,
    required this.direction,
  });

  /// Update posisi berdasarkan animasi
  void updatePosition(double animationValue) {
    final dx = cos(direction) * speed;
    final dy = sin(direction) * speed;

    // Pergerakan dengan wrapping (jika keluar layar, muncul di sisi lain)
    position = Offset((position.dx + dx) % 1.0, (position.dy + dy) % 1.0);
  }
}

/// Custom painter untuk menggambar lingkaran bokeh
class BokehPainter extends CustomPainter {
  final List<BokehCircle> circles;

  BokehPainter({required this.circles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var circle in circles) {
      // Konversi posisi relatif ke posisi absolut
      final centerX = circle.position.dx * size.width;
      final centerY = circle.position.dy * size.height;
      final radius = circle.size * min(size.width, size.height);

      // Buat gradient radial untuk efek blur
      final gradient = RadialGradient(
        colors: [circle.color, circle.color.withValues(alpha: 0.0)],
      );

      // Gambar lingkaran dengan gradient
      final paint =
          Paint()
            ..shader = gradient.createShader(
              Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
            )
            ..blendMode = BlendMode.screen; // Blend mode untuk efek glow

      canvas.drawCircle(Offset(centerX, centerY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BokehPainter oldDelegate) => true;
}
