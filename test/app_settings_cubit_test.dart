import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuang/state/app_settings_cubit.dart';
import 'package:tuang/models/character_skin.dart';

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
      expect(cubit.state.dailyMagnetBuffSeconds, 20);
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

  group('AppSettingsCubit skin management', () {
    test('skin operations work correctly', () async {
      SharedPreferences.setMockInitialValues({
        'pref_coins': 1000,
        'pref_activeSkinId': 'default',
        'pref_unlockedSkinIds': ['default'],
      });

      final cubit = AppSettingsCubit();
      await cubit.load();

      // Verifikasi state awal
      expect(cubit.state.activeSkinId, equals('default'));
      expect(cubit.state.unlockedSkinIds, contains('default'));
      expect(cubit.state.coins, equals(1000));

      // Verifikasi getAllSkins mengembalikan semua skin
      final allSkins = cubit.getAllSkins();
      expect(allSkins.length, equals(CharacterSkin.defaultSkins.length));

      // Verifikasi isSkinUnlocked
      expect(cubit.isSkinUnlocked('default'), isTrue);
      expect(cubit.isSkinUnlocked('red'), isFalse);

      // Beli skin baru
      final redSkin = CharacterSkin.defaultSkins.firstWhere(
        (s) => s.id == 'red',
      );
      expect(cubit.purchaseSkin('red'), isTrue);
      expect(cubit.state.coins, equals(1000 - redSkin.price));
      expect(cubit.state.unlockedSkinIds, contains('red'));

      // Debug: print state sebelum setActiveSkin
      // debug removed
      // Set skin aktif
      cubit.setActiveSkin('red');

      // Tunggu sebentar untuk memastikan persistence selesai
      await Future.delayed(Duration(milliseconds: 10));

      expect(cubit.state.activeSkinId, equals('red'));

      // Verifikasi persistence
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('pref_activeSkinId'), equals('red'));
      expect(prefs.getStringList('pref_unlockedSkinIds'), contains('red'));
      expect(prefs.getInt('pref_coins'), equals(1000 - redSkin.price));

      // Turunkan koin agar tidak cukup untuk membeli purple (harga 300)
      cubit.spendCoins(cubit.state.coins - 200);
      expect(cubit.state.coins, equals(200));

      // Coba beli skin dengan koin tidak cukup
      expect(cubit.purchaseSkin('purple'), isFalse);
      expect(cubit.state.unlockedSkinIds.contains('purple'), isFalse);
    });
  });
}
