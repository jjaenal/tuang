import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../services/logging_service.dart';
import '../ui/achievement_notification.dart';
import '../ui/achievements_screen.dart';

/// AchievementService menangani pengelolaan achievement pemain.
///
/// - Menyimpan dan memuat state achievement dari `SharedPreferences`.
/// - Mengupdate progress dan memicu notifikasi saat achievement terbuka.
/// - Menyediakan akses daftar achievement via getter.
class AchievementService {
  static const String _prefsKey = 'achievements';
  final Map<AchievementType, Achievement> _achievements = {};
  final List<Achievement> _recentlyUnlocked = [];

  /// Notifier untuk achievement yang baru terbuka (untuk overlay notifikasi)
  final ValueNotifier<Achievement?> onAchievementUnlocked = ValueNotifier(null);

  /// Singleton instance
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;

  AchievementService._internal() {
    _initializeAchievements();
  }

  /// Inisialisasi daftar achievement default
  void _initializeAchievements() {
    // Score-based achievements
    _registerAchievement(AchievementType.score100, 100);
    _registerAchievement(AchievementType.score500, 500);
    _registerAchievement(AchievementType.score1000, 1000);

    // Coin-based achievements
    _registerAchievement(AchievementType.collect10Coins, 10);
    _registerAchievement(AchievementType.collect50Coins, 50);
    _registerAchievement(AchievementType.collect100Coins, 100);

    // Gameplay achievements
    _registerAchievement(AchievementType.firstGame, 1);
    _registerAchievement(AchievementType.play10Games, 10);
    _registerAchievement(AchievementType.play50Games, 50);

    // Special achievements
    _registerAchievement(AchievementType.useMagnet, 1);
    _registerAchievement(AchievementType.reviveOnce, 1);

    // Load saved achievements
    loadAchievements();
  }

  /// Mendaftarkan achievement baru dengan target bawaan
  void _registerAchievement(AchievementType type, int targetValue) {
    _achievements[type] = Achievement.create(type, targetValue: targetValue);
  }

  /// Mendapatkan semua achievement
  List<Achievement> getAllAchievements() {
    return _achievements.values.toList();
  }

  /// Mendapatkan achievement yang sudah terbuka
  List<Achievement> getUnlockedAchievements() {
    return _achievements.values.where((a) => a.isUnlocked).toList();
  }

  /// Mendapatkan achievement yang belum terbuka
  List<Achievement> getLockedAchievements() {
    return _achievements.values.where((a) => !a.isUnlocked).toList();
  }

  /// Mendapatkan achievement berdasarkan tipe
  Achievement? getAchievement(AchievementType type) {
    return _achievements[type];
  }

  /// Mendapatkan achievement yang baru saja terbuka
  List<Achievement> getRecentlyUnlocked() {
    return List.from(_recentlyUnlocked);
  }

  /// Mengupdate progress achievement dan memicu notifikasi jika terbuka
  void updateProgress(AchievementType type, int progress) {
    final achievement = _achievements[type];
    if (achievement == null) return;

    final updatedAchievement = achievement.updateProgress(progress);
    _achievements[type] = updatedAchievement;

    // Cek apakah achievement baru terbuka
    if (updatedAchievement.isUnlocked &&
        (achievement.unlockedAt == null ||
            achievement.unlockedAt != updatedAchievement.unlockedAt)) {
      _recentlyUnlocked.add(updatedAchievement);
      onAchievementUnlocked.value = updatedAchievement;
      LoggingService.log(
        'Achievement unlocked: ${updatedAchievement.type.title}',
      );
    }

    // Simpan perubahan
    saveAchievements();
  }

  /// Increment progress achievement
  void incrementProgress(AchievementType type, [int increment = 1]) {
    final achievement = _achievements[type];
    if (achievement == null) return;

    updateProgress(type, achievement.progress + increment);
  }

  /// Menyimpan achievement ke `SharedPreferences` (JSON-encoded list)
  Future<void> saveAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson =
          _achievements.values
              .map((achievement) => achievement.toJson())
              .toList();

      await prefs.setString(_prefsKey, jsonEncode(achievementsJson));
    } catch (e) {
      LoggingService.log('Error saving achievements: $e');
    }
  }

  /// Memuat achievement dari `SharedPreferences`
  Future<void> loadAchievements() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final achievementsJson = prefs.getString(_prefsKey);

      if (achievementsJson != null) {
        final List<dynamic> decodedList = jsonDecode(achievementsJson);

        for (final item in decodedList) {
          final achievement = Achievement.fromJson(item);
          _achievements[achievement.type] = achievement;
        }
      }
    } catch (e) {
      LoggingService.log('Error loading achievements: $e');
    }
  }

  /// Reset semua achievement (untuk debugging)
  Future<void> resetAllAchievements() async {
    _achievements.clear();
    _recentlyUnlocked.clear();
    _initializeAchievements();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      LoggingService.log('Error resetting achievements: $e');
    }
  }

  /// Menandai achievement yang baru terbuka sudah dilihat
  void clearRecentlyUnlocked() {
    _recentlyUnlocked.clear();
  }

  /// Menampilkan notifikasi untuk achievement yang baru terbuka
  void showNotification(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder:
          (context) => AchievementNotification(
            achievement: achievement,
            onDismiss: () {
              entry.remove();
            },
          ),
    );

    overlay.insert(entry);
    // Clear the notifier to avoid duplicate notifications from multiple listeners
    onAchievementUnlocked.value = null;
  }

  /// Menampilkan layar achievements
  void showAchievements(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AchievementsScreen()));
  }

  /// Singleton accessor
  static AchievementService get I => _instance;
}
