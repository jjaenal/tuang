import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/game_theme.dart';

/// Renders a themed background using the active GameTheme's CustomPaint renderer.
class ThemeBackground extends PositionComponent with HasGameRef<FlameGame> {
  ThemeBackground({required GameTheme theme}) : _theme = theme;

  GameTheme _theme;

  void setTheme(GameTheme theme) {
    _theme = theme;
  }

  @override
  Future<void> onLoad() async {
    // Cover entire game area; keep at the very back.
    priority = -1000;
    position = Vector2.zero();
    size = gameRef.size;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    size = size;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final renderer = _theme.paintTheme.renderer;

    // Fill base color softly for overall tone
    final bgPaint = Paint()..color = _theme.color.withValues(alpha: 0.25);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), bgPaint);

    // Convert Flame's Vector2 size to Flutter's Size for the renderer.
    final s = Size(size.x, size.y);
    renderer.renderBackground(canvas, s);
  }
}
