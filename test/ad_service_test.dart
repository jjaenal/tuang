import 'package:flutter_test/flutter_test.dart';
import 'package:tuang/services/ad_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  group('AdService cooldownAllows', () {
    test('allows when last is null', () {
      final now = DateTime(2025, 1, 1, 12, 0, 0);
      expect(
        AdService.cooldownAllows(null, now, const Duration(seconds: 120)),
        isTrue,
      );
    });

    test('blocks when cooldown not met', () {
      final last = DateTime(2025, 1, 1, 12, 0, 0);
      final now = DateTime(2025, 1, 1, 12, 1, 0); // 60s later
      expect(
        AdService.cooldownAllows(last, now, const Duration(seconds: 120)),
        isFalse,
      );
    });

    test('allows when cooldown met', () {
      final last = DateTime(2025, 1, 1, 12, 0, 0);
      final now = DateTime(2025, 1, 1, 12, 2, 0); // 120s later
      expect(
        AdService.cooldownAllows(last, now, const Duration(seconds: 120)),
        isTrue,
      );
    });
  });

  group('AdService rewarded flows (logic-only)', () {
    test('showRewardedRevive returns false when not initialized', () async {
      final ad = AdService.I;
      // Pastikan state bersih
      await Future.value();
      final result = await ad.showRewardedRevive();
      expect(result, isFalse);
    });

    test('showRewardedDailyReward returns false when not initialized', () async {
      final ad = AdService.I;
      final result = await ad.showRewardedDailyReward();
      expect(result, isFalse);
    });

    test('setNonPersonalizedAds does not throw before init', () {
      final ad = AdService.I;
      expect(() => ad.setNonPersonalizedAds(true), returnsNormally);
    });
  });
}
