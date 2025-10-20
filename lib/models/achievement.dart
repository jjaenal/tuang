import 'package:flutter/material.dart';

/// Jenis achievement yang dapat diperoleh pemain
enum AchievementType {
  // Score-based achievements
  score100('Score Hunter I', 'Dapatkan skor 100', Icons.emoji_events),
  score500('Score Hunter II', 'Dapatkan skor 500', Icons.emoji_events),
  score1000('Score Hunter III', 'Dapatkan skor 1000', Icons.emoji_events),

  // Coin-based achievements
  collect10Coins(
    'Coin Collector I',
    'Kumpulkan 10 koin',
    Icons.monetization_on,
  ),
  collect50Coins(
    'Coin Collector II',
    'Kumpulkan 50 koin',
    Icons.monetization_on,
  ),
  collect100Coins(
    'Coin Collector III',
    'Kumpulkan 100 koin',
    Icons.monetization_on,
  ),

  // Gameplay achievements
  firstGame('Pemula', 'Mainkan game pertama kali', Icons.sports_esports),
  play10Games('Enthusiast', 'Mainkan 10 game', Icons.sports_esports),
  play50Games('Addict', 'Mainkan 50 game', Icons.sports_esports),

  // Special achievements
  useMagnet('Magnetic', 'Gunakan magnet pertama kali', Icons.bolt),
  reviveOnce('Second Chance', 'Gunakan fitur revive', Icons.replay);

  final String title;
  final String description;
  final IconData icon;

  const AchievementType(this.title, this.description, this.icon);
}

/// Model untuk menyimpan data achievement
class Achievement {
  final AchievementType type;
  final DateTime? unlockedAt;
  final int progress;
  final int targetValue;

  /// Menunjukkan apakah achievement sudah terbuka
  bool get isUnlocked => unlockedAt != null;

  /// Persentase progress achievement (0-100)
  int get progressPercent =>
      (progress / targetValue * 100).clamp(0, 100).toInt();

  const Achievement({
    required this.type,
    this.unlockedAt,
    required this.progress,
    required this.targetValue,
  });

  /// Membuat salinan achievement dengan nilai yang diperbarui
  Achievement copyWith({
    AchievementType? type,
    DateTime? unlockedAt,
    int? progress,
    int? targetValue,
  }) {
    return Achievement(
      type: type ?? this.type,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      progress: progress ?? this.progress,
      targetValue: targetValue ?? this.targetValue,
    );
  }

  /// Membuat achievement baru dengan progress yang diperbarui
  /// dan mengecek apakah achievement sudah terbuka
  Achievement updateProgress(int newProgress) {
    final updatedProgress = newProgress;

    // Cek apakah achievement sudah terbuka
    if (updatedProgress >= targetValue && !isUnlocked) {
      return copyWith(progress: updatedProgress, unlockedAt: DateTime.now());
    }

    return copyWith(progress: updatedProgress);
  }

  /// Mengkonversi achievement ke format JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'progress': progress,
      'targetValue': targetValue,
    };
  }

  /// Membuat achievement dari format JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      type: AchievementType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AchievementType.firstGame,
      ),
      unlockedAt:
          json['unlockedAt'] != null
              ? DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'])
              : null,
      progress: json['progress'] ?? 0,
      targetValue: json['targetValue'] ?? 1,
    );
  }

  /// Membuat achievement baru dengan nilai default
  factory Achievement.create(AchievementType type, {int targetValue = 1}) {
    return Achievement(type: type, progress: 0, targetValue: targetValue);
  }
}
