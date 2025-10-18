import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/state/app_settings_cubit.dart';

void main() {
  group('AppSettingsCubit persistence', () {
    test('load reads saved values and toggles persist', () async {
      SharedPreferences.setMockInitialValues({
        'pref_audioOn': false,
        'pref_consentGiven': false,
        'pref_adsEnabled': false,
        'pref_paused': false,
      });
      final cubit = AppSettingsCubit();
      await cubit.load();
      expect(cubit.state.audioOn, isFalse);

      cubit.toggleAudio();
      expect(cubit.state.audioOn, isTrue);

      // saved value should be true
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('pref_audioOn'), isTrue);

      cubit.setConsent(true);
      expect(cubit.state.consentGiven, isTrue);

      cubit.toggleAds();
      expect(cubit.state.adsEnabled, isTrue);

      cubit.setPaused(true);
      expect(cubit.state.paused, isTrue);
    });
  });
}