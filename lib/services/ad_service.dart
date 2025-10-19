import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService I = AdService._();
  AdService._();

  bool _initialized = false;
  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  
  /// Slot rewarded terpisah untuk Daily Reward agar tidak berbenturan dengan Revive.
  RewardedAd? _rewardedDaily;

  DateTime? _lastInterstitialShown;
  Duration interstitialCooldown = const Duration(seconds: 120);

  // Provider waktu untuk pengujian
  static DateTime Function() nowProvider = () => DateTime.now();

  // Preferensi Non-Personalized Ads
  bool _npa = false;

  void _log(String msg) {
    debugPrint('[AdService] $msg');
  }

  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // fokus Android/iOS
    _log('init start');
    await MobileAds.instance.initialize();
    _initialized = true;
    _log('initialized');
    preloadInterstitial();
    preloadRewardedRevive();
    // Preload Daily Reward agar siap ketika user membuka main menu.
    preloadRewardedDailyReward();
  }

  /// Set Non-Personalized Ads preference dan reload ads yang sudah di-preload.
  void setNonPersonalizedAds(bool enable) {
    _npa = enable;
    if (!_initialized || kIsWeb) return;
    try {
      _interstitial?.dispose();
    } catch (_) {}
    _interstitial = null;
    try {
      _rewarded?.dispose();
    } catch (_) {}
    _rewarded = null;
    try {
      _rewardedDaily?.dispose();
    } catch (_) {}
    _rewardedDaily = null;
    preloadInterstitial();
    preloadRewardedRevive();
    preloadRewardedDailyReward();
  }

  // Preload interstitial sehingga siap ditampilkan tanpa menunggu
  void preloadInterstitial() {
    if (!_initialized || kIsWeb) return;
    _log('preload interstitial');
    InterstitialAd.load(
      adUnitId: _interstitialUnitId(),
      request: AdRequest(nonPersonalizedAds: _npa),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad;
          _log('interstitial loaded');
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _log('interstitial failed: ${err.message}');
        },
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
      _log('interstitial blocked by cooldown');
      return false;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) => _log('interstitial shown'),
      onAdDismissedFullScreenContent: (ad) {
        _log('interstitial dismissed');
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('interstitial failed to show: ${err.message}');
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
    );
    _lastInterstitialShown = now;
    _log('interstitial show()');
    ad.show();
    return true; // kita anggap ter-trigger; result final via callback
  }

  // Preload rewarded ad untuk revive agar UX mulus
  void preloadRewardedRevive() {
    if (!_initialized || kIsWeb) return;
    _log('preload rewarded revive');
    RewardedAd.load(
      adUnitId: _rewardedUnitId(),
      request: AdRequest(nonPersonalizedAds: _npa),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad;
          _log('rewarded revive loaded');
        },
        onAdFailedToLoad: (err) {
          _rewarded = null;
          _log('rewarded revive failed: ${err.message}');
        },
      ),
    );
  }

  // Tampilkan rewarded; return true bila pengguna memperoleh reward (menyelesaikan tontonan)
  Future<bool> showRewardedRevive() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _rewarded;
    if (ad == null) return false;
    bool rewarded = false;
    _log('show rewarded revive');
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log('rewarded revive dismissed');
        ad.dispose();
        _rewarded = null;
        preloadRewardedRevive();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('rewarded revive failed to show: ${err.message}');
        ad.dispose();
        _rewarded = null;
        rewarded = false;
        preloadRewardedRevive();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        _log('rewarded revive earned: ${reward.amount} ${reward.type}');
        rewarded = true;
      },
    );
    return rewarded;
  }

  /// Preload rewarded ad untuk Daily Reward dengan slot terpisah.
  /// Memastikan ketersediaan iklan ketika user menekan tombol Daily Reward.
  void preloadRewardedDailyReward() {
    if (!_initialized || kIsWeb) return;
    _log('preload rewarded daily');
    RewardedAd.load(
      adUnitId: _rewardedUnitId(),
      request: AdRequest(nonPersonalizedAds: _npa),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedDaily = ad;
          _log('rewarded daily loaded');
        },
        onAdFailedToLoad: (err) {
          _rewardedDaily = null;
          _log('rewarded daily failed: ${err.message}');
        },
      ),
    );
  }

  /// Menampilkan rewarded untuk Daily Reward.
  /// Mengembalikan true bila pengguna menuntaskan tontonan (reward diperoleh).
  Future<bool> showRewardedDailyReward() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _rewardedDaily;
    if (ad == null) return false;
    bool rewarded = false;
    _log('show rewarded daily');
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log('rewarded daily dismissed');
        ad.dispose();
        _rewardedDaily = null;
        preloadRewardedDailyReward();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('rewarded daily failed to show: ${err.message}');
        ad.dispose();
        _rewardedDaily = null;
        rewarded = false;
        preloadRewardedDailyReward();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        _log('rewarded daily earned: ${reward.amount} ${reward.type}');
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

  // Unit ID banner untuk test (Android/iOS)
  String bannerUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'ca-app-pub-3940256099942544/6300978111';
      case TargetPlatform.iOS:
        return 'ca-app-pub-3940256099942544/2934735716';
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
