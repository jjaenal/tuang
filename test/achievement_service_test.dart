import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/services/achievement_service.dart';
import 'package:tuang/models/achievement.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('Unlock score100 when progress meets threshold', () async {
    final svc = AchievementService.I;
    await svc.resetAllAchievements();

    expect(svc.getAchievement(AchievementType.score100)!.isUnlocked, isFalse);

    svc.updateProgress(AchievementType.score100, 100);

    expect(svc.getAchievement(AchievementType.score100)!.isUnlocked, isTrue);
    expect(
      svc.getRecentlyUnlocked().any((a) => a.type == AchievementType.score100),
      isTrue,
    );
  });

  test('Increment coins accumulates and unlocks collect10Coins', () async {
    final svc = AchievementService.I;
    await svc.resetAllAchievements();

    for (int i = 0; i < 10; i++) {
      svc.incrementProgress(AchievementType.collect10Coins);
    }

    expect(
      svc.getAchievement(AchievementType.collect10Coins)!.isUnlocked,
      isTrue,
    );
  });

  test('Persistence: save and load achievements', () async {
    final svc = AchievementService.I;
    await svc.resetAllAchievements();

    svc.updateProgress(AchievementType.play10Games, 10);
    expect(svc.getAchievement(AchievementType.play10Games)!.isUnlocked, isTrue);

    await svc.saveAchievements();
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('achievements');
    expect(saved, isNotNull);

    // Reset to default then restore saved json and load
    await svc.resetAllAchievements();
    await prefs.setString('achievements', saved!);
    await svc.loadAchievements();

    expect(svc.getAchievement(AchievementType.play10Games)!.isUnlocked, isTrue);
  });
}
