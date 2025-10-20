import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/state/app_settings_cubit.dart';

void main() {
  group('AppSettingsCubit persistence', () {
    test('dailyMagnetBuffSeconds loads and persists', () async {
      SharedPreferences.setMockInitialValues({'pref_dailyMagnetBuffSec': 7});
      final cubit = AppSettingsCubit();
      await cubit.load();
      expect(cubit.state.dailyMagnetBuffSeconds, 7);

      cubit.setDailyMagnetBuffSeconds(10);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.dailyMagnetBuffSeconds, 10);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_dailyMagnetBuffSec'), 10);

      cubit.setDailyMagnetBuffSeconds(-3);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.dailyMagnetBuffSeconds, 0);

      cubit.setDailyMagnetBuffSeconds(99);
      await Future.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.dailyMagnetBuffSeconds, 15);
    });

    test('load reads saved values and toggles persist', () async {
      SharedPreferences.setMockInitialValues({
        'pref_audioOn': false,
        'pref_consentGiven': false,
        'pref_adsEnabled': false,
        'pref_paused': false,
        'pref_hapticsOn': false,
      });
      final cubit = AppSettingsCubit();
      await cubit.load();
      expect(cubit.state.audioOn, isFalse);
      expect(cubit.state.hapticsOn, isFalse);

      cubit.toggleAudio();
      expect(cubit.state.audioOn, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_audioOn'), isTrue);

      cubit.toggleHaptics();
      expect(cubit.state.hapticsOn, isTrue);
      final prefs2 = await SharedPreferences.getInstance();
      expect(prefs2.getBool('pref_hapticsOn'), isTrue);

      cubit.setConsent(true);
      expect(cubit.state.consentGiven, isTrue);

      cubit.toggleAds();
      expect(cubit.state.adsEnabled, isTrue);

      cubit.setPaused(true);
      expect(cubit.state.paused, isTrue);
    });
  });
}
