import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import 'theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen untuk menampilkan daftar achievements
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();

  /// Membangun scaffold dengan header progress dan daftar achievements.
  @override
  Widget build(BuildContext context) {
    final allAchievements = _achievementService.getAllAchievements();
    final unlockedCount = _achievementService.getUnlockedAchievements().length;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.achievementsTitle),
        centerTitle: true,
        backgroundColor: AppTheme.darkBase,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.darkGradient),
        child: Column(
          children: [
            _buildProgressHeader(unlockedCount, allAchievements.length, l10n),
            Expanded(child: _buildAchievementsList(allAchievements)),
          ],
        ),
      ),
    );
  }

  /// Widget untuk menampilkan header dengan progress achievement
  Widget _buildProgressHeader(int unlocked, int total, AppLocalizations l10n) {
    final progressPercent = total > 0 ? (unlocked / total * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.darkBase,
      child: Column(
        children: [
          Text(
            l10n.achievementsProgress(unlocked, total),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: total > 0 ? unlocked / total : 0,
            backgroundColor: AppTheme.darkBase.withAlpha(100),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.achievementsCompletedPercent(progressPercent),
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
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      color:
          isUnlocked
              ? AppTheme.darkBase.withAlpha(200)
              : AppTheme.darkBase.withAlpha(100),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.amber : Colors.grey.shade600,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement.type.icon,
            color: isUnlocked ? Colors.white : Colors.grey.shade300,
          ),
        ),
        title: Text(
          l10n.achievementTitle(achievement.type.name),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? Colors.white : Colors.grey.shade400,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.achievementDesc(achievement.type.name),
              style: TextStyle(
                color: isUnlocked ? Colors.grey.shade300 : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value:
                  achievement.targetValue > 0
                      ? achievement.progress / achievement.targetValue
                      : 0,
              backgroundColor: AppTheme.darkBase.withAlpha(100),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? Colors.green : Colors.amber,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${achievement.progress}/${achievement.targetValue}',
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? Colors.green : Colors.amber,
              ),
            ),
          ],
        ),
        trailing:
            isUnlocked
                ? const Icon(Icons.check_circle, color: Colors.green)
                : Icon(Icons.lock_outline, color: Colors.grey.shade500),
      ),
    );
  }
}
