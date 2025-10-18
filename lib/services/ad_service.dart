import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService I = AdService._();
  AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;

  DateTime? _lastInterstitialShown;
  Duration interstitialCooldown = const Duration(seconds: 120);

  // Provider waktu untuk pengujian
  static DateTime Function() nowProvider = () => DateTime.now();

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // fokus Android/iOS
    await MobileAds.instance.initialize();
    _initialized = true;
    preloadInterstitial();
    preloadRewardedRevive();
  }

  // Preload interstitial sehingga siap ditampilkan tanpa menunggu
  void preloadInterstitial() {
    if (!_initialized || kIsWeb) return;
    InterstitialAd.load(
      adUnitId: _interstitialUnitId(),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (err) => _interstitial = null,
      ),
    );
  }

  // Menampilkan interstitial dengan cooldown agar tidak terlalu sering
  Future<bool> showInterstitial() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _interstitial;
    if (ad == null) return false;
    final now = nowProvider();
    if (!cooldownAllows(_lastInterstitialShown, now, interstitialCooldown)) {
      return false;
    }
    bool shown = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {},
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        shown = true;
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _interstitial = null;
        shown = false;
        preloadInterstitial();
      },
    );
    _lastInterstitialShown = now;
    ad.show();
    return true; // kita anggap ter-trigger; result final via callback
  }

  // Preload rewarded ad untuk revive agar UX mulus
  void preloadRewardedRevive() {
    if (!_initialized || kIsWeb) return;
    RewardedAd.load(
      adUnitId: _rewardedUnitId(),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewarded = ad,
        onAdFailedToLoad: (err) => _rewarded = null,
      ),
    );
  }

  // Tampilkan rewarded; return true bila pengguna memperoleh reward (menyelesaikan tontonan)
  Future<bool> showRewardedRevive() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _rewarded;
    if (ad == null) return false;
    bool rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewarded = null;
        preloadRewardedRevive();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _rewarded = null;
        rewarded = false;
        preloadRewardedRevive();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        rewarded = true;
      },
    );
    return rewarded;
  }

  // Test IDs
  String _interstitialUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/1033173712';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/4411468910';
      default:
        return '';
    }
  }

  String _rewardedUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/5224354917';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/1712485313';
      default:
        return '';
    }
  }

  @visibleForTesting
  static bool cooldownAllows(DateTime? last, DateTime now, Duration cooldown) {
    // Mengizinkan bila belum pernah tampil atau jarak waktu >= cooldown
    if (last == null) return true;
    return now.difference(last) >= cooldown;
  }
}
