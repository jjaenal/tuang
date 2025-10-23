enum Difficulty { easy, normal, hard }

extension DifficultyX on Difficulty {
  String get key => switch (this) {
    Difficulty.easy => 'easy',
    Difficulty.normal => 'normal',
    Difficulty.hard => 'hard',
  };

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