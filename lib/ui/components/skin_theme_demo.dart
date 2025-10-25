import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import '../../game/skin_renderer.dart';
import '../../models/skin_type.dart';
import '../theme/custom_paint_themes.dart';

/// [SkinThemeDemo] adalah widget demo untuk menampilkan CustomPaint skins dan themes.
///
/// Widget ini memungkinkan testing visual dari berbagai kombinasi skin dan tema
/// yang tersedia dalam aplikasi.
class SkinThemeDemo extends StatefulWidget {
  const SkinThemeDemo({super.key});

  @override
  State<SkinThemeDemo> createState() => _SkinThemeDemoState();
}

class _SkinThemeDemoState extends State<SkinThemeDemo> {
  SkinType selectedSkinType = SkinType.basic;
  CustomPaintTheme selectedTheme = CustomPaintTheme.geometric;
  bool useCustomPaintSkins = true;
  bool showBoostEffect = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin & Theme Demo'),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            _buildControls(),
            const SizedBox(height: 24),
            
            // Skin Demo
            _buildSkinDemo(),
            const SizedBox(height: 32),
            
            // Theme Demo
            _buildThemeDemo(),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return ThemedCustomPaint(
      theme: selectedTheme,
      size: const Size(double.infinity, 200),
      baseColor: Colors.grey[900],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Controls',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Skin Type Selector
            Row(
              children: [
                const Text('Skin Type: ', style: TextStyle(color: Colors.white)),
                DropdownButton<SkinType>(
                  value: selectedSkinType,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: SkinType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSkinType = value;
                      });
                    }
                  },
                ),
              ],
            ),
            
            // Theme Selector
            Row(
              children: [
                const Text('Theme: ', style: TextStyle(color: Colors.white)),
                DropdownButton<CustomPaintTheme>(
                  value: selectedTheme,
                  dropdownColor: Colors.grey[800],
                  style: const TextStyle(color: Colors.white),
                  items: CustomPaintTheme.values.map((theme) {
                    return DropdownMenuItem(
                      value: theme,
                      child: Text(theme.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedTheme = value;
                      });
                    }
                  },
                ),
              ],
            ),
            
            // Toggles
            Row(
              children: [
                Checkbox(
                  value: useCustomPaintSkins,
                  onChanged: (value) {
                    setState(() {
                      useCustomPaintSkins = value ?? true;
                    });
                  },
                ),
                const Text('Use CustomPaint Skins', style: TextStyle(color: Colors.white)),
                const SizedBox(width: 20),
                Checkbox(
                  value: showBoostEffect,
                  onChanged: (value) {
                    setState(() {
                      showBoostEffect = value ?? false;
                    });
                  },
                ),
                const Text('Boost Effect', style: TextStyle(color: Colors.white)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Character Skins',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Skin showcase
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: SkinType.values.map((skinType) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    skinType.name.toUpperCase(),
                    style: TextStyle(
                      color: skinType == selectedSkinType ? Colors.yellow : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: skinType == selectedSkinType ? Colors.yellow : Colors.grey,
                        width: skinType == selectedSkinType ? 2 : 1,
                      ),
                    ),
                    child: CustomPaint(
                      painter: _SkinPainter(
                        skinType: skinType,
                        useCustomPaint: useCustomPaintSkins,
                        isBoost: showBoostEffect,
                        color: _getSkinColor(skinType),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeDemo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'UI Themes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Theme showcase
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // Button demo
            _buildThemeComponent(
              'Button',
              (canvas, size) => selectedTheme.renderer.renderButton(
                canvas,
                size,
                color: Colors.blue,
                isPressed: false,
              ),
            ),
            
            // Pressed button demo
            _buildThemeComponent(
              'Pressed Button',
              (canvas, size) => selectedTheme.renderer.renderButton(
                canvas,
                size,
                color: Colors.blue,
                isPressed: true,
              ),
            ),
            
            // Panel demo
            _buildThemeComponent(
              'Panel',
              (canvas, size) => selectedTheme.renderer.renderPanel(
                canvas,
                size,
                backgroundColor: Colors.grey[800]!,
                elevated: true,
              ),
            ),
            
            // Progress bar demo
            _buildThemeComponent(
              'Progress Bar',
              (canvas, size) => selectedTheme.renderer.renderProgressBar(
                canvas,
                size,
                progress: 0.7,
                fillColor: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeComponent(String title, void Function(Canvas, Size) painter) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 120,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[700]!),
          ),
          child: CustomPaint(
            painter: _ThemePainter(painter),
          ),
        ),
      ],
    );
  }

  Color _getSkinColor(SkinType skinType) {
    switch (skinType) {
      case SkinType.basic:
        return Colors.blue;
      case SkinType.advanced:
        return Colors.purple;
      case SkinType.premium:
        return Colors.orange;
      case SkinType.legendary:
        return Colors.amber;
    }
  }
}

class _SkinPainter extends CustomPainter {
  final SkinType skinType;
  final bool useCustomPaint;
  final bool isBoost;
  final Color color;

  _SkinPainter({
    required this.skinType,
    required this.useCustomPaint,
    required this.isBoost,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final renderer = SkinRenderer.create(
      skinType,
      color,
      useCustomPaint: useCustomPaint,
    );
    
    renderer.render(
      canvas,
      Vector2(size.width, size.height),
      isBoost: isBoost,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ThemePainter extends CustomPainter {
  final void Function(Canvas, Size) painter;

  _ThemePainter(this.painter);

  @override
  void paint(Canvas canvas, Size size) {
    painter(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}