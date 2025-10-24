import 'package:flutter/material.dart';
import 'skin_type.dart';

/// Model untuk skin karakter yang tersedia dalam game
class CharacterSkin {
  /// ID unik untuk skin
  final String id;

  /// Nama skin yang ditampilkan ke user
  final String name;

  /// Warna utama skin
  final Color color;

  /// Harga skin dalam coins (0 untuk skin default/gratis)
  final int price;

  /// Path ke asset gambar (opsional, untuk future implementation)
  final String? imagePath;

  /// Apakah skin ini sudah terbuka/dimiliki oleh player
  final bool isUnlocked;

  /// Tipe skin yang menentukan kompleksitas render
  final SkinType skinType;

  CharacterSkin({
    required this.id,
    required this.name,
    required this.color,
    required this.price,
    this.imagePath,
    this.isUnlocked = false,
    SkinType? skinType,
  }) : skinType = skinType ?? SkinType.fromPrice(price);

  /// Membuat copy dari skin dengan beberapa properti yang diubah
  CharacterSkin copyWith({
    String? id,
    String? name,
    Color? color,
    int? price,
    String? imagePath,
    bool? isUnlocked,
    SkinType? skinType,
  }) {
    return CharacterSkin(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      price: price ?? this.price,
      imagePath: imagePath ?? this.imagePath,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      skinType: skinType ?? this.skinType,
    );
  }

  // Menentukan tipe skin berdasarkan harga
  SkinType get skinType => SkinType.fromPrice(price);

  /// Daftar skin default yang tersedia dalam game
  static List<CharacterSkin> defaultSkins = [
    CharacterSkin(
      id: 'default',
      name: 'Default',
      color: Colors.blue,
      price: 0,
      imagePath: 'bird.png',
      isUnlocked: true,
    ),
    CharacterSkin(
      id: 'red',
      name: 'Merah',
      color: Colors.red,
      price: 100,
      imagePath: 'bird_red.png',
    ),
    CharacterSkin(
      id: 'green',
      name: 'Hijau',
      color: Colors.green,
      price: 200,
      imagePath: 'bird_green.png',
    ),
    CharacterSkin(
      id: 'purple',
      name: 'Ungu',
      color: Colors.purple,
      price: 300,
      imagePath: 'bird_purple.png',
    ),
    CharacterSkin(
      id: 'orange',
      name: 'Oranye',
      color: Colors.orange,
      price: 500,
      imagePath: 'bird_orange.png',
    ),
  ];
}
