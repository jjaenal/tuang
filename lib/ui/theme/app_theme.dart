import 'package:flutter/material.dart';

/// Konfigurasi tema aplikasi terpusat
///
/// Kelas ini menyediakan konstanta warna dan konfigurasi tema
/// yang digunakan di seluruh aplikasi untuk konsistensi visual.
class AppTheme {
  // Warna dasar
  static const Color darkBase = Color(0xFF1A1F24);
  static const Color darkHeader = Color(0xFF20252B);
  static const Color lightBase = Color(0xFF5B3A1A);
  static const Color lightHeader = Color(0xFFCC9A53);
  static const Color lightBorderColor = Color(0xFFB2834A);

  // Warna barrier dialog
  static Color barrierColorDark = const Color(
    0xFF1A1F24,
  ).withAlpha(153); // 0.6 opacity = 153 alpha
  static Color barrierColorLight = Colors.black54;

  // Gradien
  static const LinearGradient darkGradient = LinearGradient(
    colors: [darkHeader, darkBase],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient lightGradient = LinearGradient(
    colors: [Color(0xFF6B481F), Color(0xFF4A2F14)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Border
  static final Border darkBorder = Border.all(color: Colors.white12, width: 1);

  static final Border lightBorder = Border.all(
    color: lightBorderColor,
    width: 2,
  );

  // Shadow
  static const List<BoxShadow> darkShadow = [];
  static const List<BoxShadow> lightShadow = [
    BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 4)),
  ];
}
