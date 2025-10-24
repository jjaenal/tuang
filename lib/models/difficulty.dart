/// Tingkat kesulitan permainan
/// Menentukan parameter gameplay seperti kecepatan obstacle, spawn, dsb.
enum Difficulty { easy, normal, hard }

/// Ekstensi utilitas untuk konversi dan key string
extension DifficultyX on Difficulty {
  /// Key string yang konsisten untuk penyimpanan/preferences
  String get key => switch (this) {
    Difficulty.easy => 'easy',
    Difficulty.normal => 'normal',
    Difficulty.hard => 'hard',
  };

  /// Parse `Difficulty` dari key string (fallback ke `normal`)
  static Difficulty fromKey(String? key) {
    switch (key) {
      case 'easy':
        return Difficulty.easy;
      case 'hard':
        return Difficulty.hard;
      case 'normal':
      default:
        return Difficulty.normal;
    }
  }
}
