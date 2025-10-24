/// Enum untuk menentukan tingkat kompleksitas skin player
/// Semakin tinggi level, semakin kompleks bentuk dan animasi
enum SkinType {
  /// Skin dasar dengan bentuk sederhana
  basic,

  /// Skin menengah dengan detail tambahan
  advanced,

  /// Skin premium dengan detail kompleks dan efek khusus
  premium,

  /// Skin legendaris dengan animasi dan efek spesial
  legendary;

  /// Mendapatkan SkinType berdasarkan harga
  static SkinType fromPrice(int price) {
    if (price >= 500) {
      return SkinType.legendary;
    } else if (price >= 300) {
      return SkinType.premium;
    } else if (price >= 100) {
      return SkinType.advanced;
    } else {
      return SkinType.basic;
    }
  }
}