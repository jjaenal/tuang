import 'package:flutter/material.dart';
import 'theme_type.dart';
import '../ui/theme/custom_paint_themes.dart';

/// Model untuk tema UI yang tersedia dalam game
///
/// Menyimpan identitas, nama tampil, warna, harga (dalam koin),
/// status kepemilikan, serta `themeType` untuk menentukan renderer.
class GameTheme {
  /// ID unik untuk tema
  final String id;

  /// Nama tema yang ditampilkan ke user
  final String name;

  /// Warna utama tema
  final Color color;

  /// Harga tema dalam coins (0 untuk tema default/gratis)
  final int price;

  /// Apakah tema ini sudah terbuka/dimiliki oleh player
  final bool isUnlocked;

  /// Tipe tema yang menentukan kompleksitas render
  final ThemeType themeType;

  /// CustomPaintTheme yang digunakan untuk rendering
  final CustomPaintTheme paintTheme;

  /// Membuat instance `GameTheme`.
  ///
  /// Jika `themeType` tidak diberikan, akan dihitung dari `price` via
  /// `ThemeType.fromPrice`.
  GameTheme({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
    required this.paintTheme,
    this.isUnlocked = false,
    ThemeType? themeType,
  }) : themeType = themeType ?? ThemeType.fromPrice(price);

  /// Membuat copy dari tema dengan beberapa properti yang diubah
  GameTheme copyWith({
    String? id,
    String? name,
    Color? color,
    int? price,
    bool? isUnlocked,
    ThemeType? themeType,
    CustomPaintTheme? paintTheme,
  }) {
    return GameTheme(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      price: price ?? this.price,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      themeType: themeType ?? this.themeType,
      paintTheme: paintTheme ?? this.paintTheme,
    );
  }

  /// Daftar tema default yang tersedia dalam game
  static List<GameTheme> defaultThemes = [
    GameTheme(
      id: 'geometric',
      name: 'Geometric',
      color: Colors.blue,
      price: 0,
      paintTheme: CustomPaintTheme.geometric,
      isUnlocked: true,
    ),
    GameTheme(
      id: 'crystal',
      name: 'Crystal',
      color: Colors.teal,
      price: 1000,
      paintTheme: CustomPaintTheme.crystal,
    ),
    GameTheme(
      id: 'neon',
      name: 'Neon',
      color: Colors.purple,
      price: 2500,
      paintTheme: CustomPaintTheme.neon,
    ),
    GameTheme(
      id: 'cosmic',
      name: 'Cosmic',
      color: Colors.deepPurple,
      price: 5000,
      paintTheme: CustomPaintTheme.cosmic,
    ),
  ];
}
