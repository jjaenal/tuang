import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/state/app_settings_cubit.dart';

void main() {
  group('AppSettingsCubit magnet buff', () {
    test('grantMagnetBuff saves pending seconds', () async {
      SharedPreferences.setMockInitialValues({});
      final cubit = AppSettingsCubit();
      await cubit.load();
      cubit.grantMagnetBuff(AppSettingsCubit.defaultDailyMagnetBuffSec);
      // Tunggu agar _savePrefs() async menyelesaikan penulisan
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(
        cubit.state.pendingMagnetBuffSeconds,
        equals(AppSettingsCubit.defaultDailyMagnetBuffSec),
      );
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getInt('pref_pendingMagnetBuffSec'),
        equals(AppSettingsCubit.defaultDailyMagnetBuffSec),
      );
    });

    test('consumeMagnetBuff returns seconds and resets to 0', () async {
      SharedPreferences.setMockInitialValues({'pref_pendingMagnetBuffSec': 8});
      final cubit = AppSettingsCubit();
      await cubit.load();
      final s = cubit.consumeMagnetBuff();
      expect(s, equals(8));
      // Tunggu agar _savePrefs() async menyelesaikan penulisan
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(cubit.state.pendingMagnetBuffSeconds, equals(0));
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('pref_pendingMagnetBuffSec'), equals(0));
    });
  });
}
