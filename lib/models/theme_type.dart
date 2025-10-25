/// Enum untuk menentukan tipe tema UI dalam game
/// Semakin tinggi level, semakin kompleks efek visual dan harga
enum ThemeType {
  /// Tema dasar dengan efek minimal
  basic,

  /// Tema menengah dengan efek visual tambahan
  advanced,

  /// Tema premium dengan efek visual kompleks
  premium,

  /// Tema legendaris dengan efek visual maksimal dan animasi
  legendary;

  /// Mendapatkan ThemeType berdasarkan harga
  ///
  /// Mapping: `>=5000 → legendary`, `>=2000 → premium`, `>=1000 → advanced`, sisanya `basic`.
  static ThemeType fromPrice(int price) {
    if (price >= 5000) {
      return ThemeType.legendary;
    } else if (price >= 2000) {
      return ThemeType.premium;
    } else if (price >= 1000) {
      return ThemeType.advanced;
    } else {
      return ThemeType.basic;
    }
  }
  
  /// Mendapatkan nama display untuk tipe tema
  String get displayName {
    switch (this) {
      case ThemeType.basic:
        return 'Basic';
      case ThemeType.advanced:
        return 'Advanced';
      case ThemeType.premium:
        return 'Premium';
      case ThemeType.legendary:
        return 'Legendary';
    }
  }
}