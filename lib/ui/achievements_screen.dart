import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';

/// Screen untuk menampilkan daftar achievements
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();

  @override
  Widget build(BuildContext context) {
    final allAchievements = _achievementService.getAllAchievements();
    final unlockedCount = _achievementService.getUnlockedAchievements().length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
      ),
      body: Column(
        children: [
          _buildProgressHeader(unlockedCount, allAchievements.length),
          Expanded(child: _buildAchievementsList(allAchievements)),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan header dengan progress achievement
  Widget _buildProgressHeader(int unlocked, int total) {
    final progressPercent = total > 0 ? (unlocked / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.blue.shade700,
      child: Column(
        children: [
          Text(
            'Achievements: $unlocked/$total',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: unlocked / total,
            backgroundColor: Colors.blue.shade300,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 4),
          Text(
            '$progressPercent% Completed',
            style: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// Widget untuk menampilkan daftar achievement
  Widget _buildAchievementsList(List<Achievement> achievements) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];
        return _buildAchievementCard(achievement);
      },
    );
  }

  /// Widget untuk menampilkan card achievement
  Widget _buildAchievementCard(Achievement achievement) {
    final bool isUnlocked = achievement.isUnlocked;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      color: isUnlocked ? Colors.blue.shade50 : Colors.grey.shade100,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.amber : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.type.icon,
            color: isUnlocked ? Colors.white : Colors.grey.shade700,
          ),
        ),
        title: Text(
          achievement.type.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.black : Colors.grey.shade700,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.type.description),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: achievement.progress / achievement.targetValue,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${achievement.progress}/${achievement.targetValue}',
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        trailing:
            isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : const Icon(Icons.lock_outline, color: Colors.grey),
      ),
    );
  }
}
