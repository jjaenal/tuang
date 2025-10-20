import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'logging_service.dart';

// Ad Unit IDs via dart-define overrides with test defaults
const String _bannerAndroidEnv = String.fromEnvironment(
  'ADMOB_BANNER_ANDROID',
  defaultValue: 'ca-app-pub-3940256099942544/6300978111',
);
const String _bannerIosEnv = String.fromEnvironment(
  'ADMOB_BANNER_IOS',
  defaultValue: 'ca-app-pub-3940256099942544/2934735716',
);
const String _interstitialAndroidEnv = String.fromEnvironment(
  'ADMOB_INTERSTITIAL_ANDROID',
  defaultValue: 'ca-app-pub-3940256099942544/1033173712',
);
const String _interstitialIosEnv = String.fromEnvironment(
  'ADMOB_INTERSTITIAL_IOS',
  defaultValue: 'ca-app-pub-3940256099942544/4411468910',
);
const String _rewardedAndroidEnv = String.fromEnvironment(
  'ADMOB_REWARDED_ANDROID',
  defaultValue: 'ca-app-pub-3940256099942544/5224354917',
);
const String _rewardedIosEnv = String.fromEnvironment(
  'ADMOB_REWARDED_IOS',
  defaultValue: 'ca-app-pub-3940256099942544/1712485313',
);

/// AdService: layanan iklan interstitial & rewarded untuk Android/iOS.
/// Mengelola init, preload, penayangan, cooldown, NPA, dan slot rewarded harian.
/// Instrumentasi melalui LoggingService: `ad_init_*`, `ad_interstitial_*`, `ad_rewarded_*`.
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

  /// Initialize Mobile Ads SDK; no-op di web.
  /// Memanggil preload untuk interstitial, rewarded (revive), dan rewarded daily.
  Future<void> init() async {
    if (_initialized) return;
    if (kIsWeb) return; // fokus Android/iOS
    _log('init start');
    LoggingService.log('ad_init_start');
    await MobileAds.instance.initialize();
    _initialized = true;
    _log('initialized');
    LoggingService.log('ad_init_done');
    preloadInterstitial();
    preloadRewardedRevive();
    // Preload Daily Reward agar siap ketika user membuka main menu.
    preloadRewardedDailyReward();
  }

  /// Set Non-Personalized Ads preference dan reload ads yang sudah di-preload.
  void setNonPersonalizedAds(bool enable) {
    _npa = enable;
    LoggingService.log('ad_npa_set', fields: {'enabled': enable});
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

  /// Preload interstitial sehingga siap ditampilkan tanpa menunggu.
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
          LoggingService.log('ad_interstitial_loaded');
        },
        onAdFailedToLoad: (err) {
          _interstitial = null;
          _log('interstitial failed: ${err.message}');
          LoggingService.log(
            'ad_interstitial_failed_load',
            fields: {'code': err.code, 'message': err.message},
          );
        },
      ),
    );
  }

  /// Menampilkan interstitial dengan cooldown agar tidak terlalu sering.
  /// Mengembalikan `true` jika pemanggilan `show()` dilakukan; hasil final via callback.
  Future<bool> showInterstitial() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _interstitial;
    if (ad == null) return false;
    final now = nowProvider();
    if (!cooldownAllows(_lastInterstitialShown, now, interstitialCooldown)) {
      _log('interstitial blocked by cooldown');
      LoggingService.log('ad_interstitial_blocked_cooldown');
      return false;
    }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (_) {
        _log('interstitial shown');
        LoggingService.log('ad_interstitial_shown');
      },
      onAdDismissedFullScreenContent: (ad) {
        _log('interstitial dismissed');
        LoggingService.log('ad_interstitial_dismissed');
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('interstitial failed to show: ${err.message}');
        LoggingService.log(
          'ad_interstitial_failed_show',
          fields: {'code': err.code, 'message': err.message},
        );
        ad.dispose();
        _interstitial = null;
        preloadInterstitial();
      },
    );
    _lastInterstitialShown = now;
    _log('interstitial show()');
    LoggingService.log('ad_interstitial_show');
    ad.show();
    return true; // kita anggap ter-trigger; result final via callback
  }

  /// Preload rewarded ad untuk Revive agar UX mulus.
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
          LoggingService.log('ad_rewarded_revive_loaded');
        },
        onAdFailedToLoad: (err) {
          _rewarded = null;
          _log('rewarded revive failed: ${err.message}');
          LoggingService.log(
            'ad_rewarded_revive_failed_load',
            fields: {'code': err.code, 'message': err.message},
          );
        },
      ),
    );
  }

  /// Tampilkan rewarded Revive; mengembalikan true bila pengguna memperoleh reward.
  Future<bool> showRewardedRevive() async {
    if (!_initialized || kIsWeb) return false;
    final ad = _rewarded;
    if (ad == null) return false;
    bool rewarded = false;
    _log('show rewarded revive');
    LoggingService.log('ad_rewarded_revive_show');
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log('rewarded revive dismissed');
        LoggingService.log('ad_rewarded_revive_dismissed');
        ad.dispose();
        _rewarded = null;
        preloadRewardedRevive();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('rewarded revive failed to show: ${err.message}');
        LoggingService.log(
          'ad_rewarded_revive_failed_show',
          fields: {'code': err.code, 'message': err.message},
        );
        ad.dispose();
        _rewarded = null;
        rewarded = false;
        preloadRewardedRevive();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        _log('rewarded revive earned: ${reward.amount} ${reward.type}');
        LoggingService.log(
          'ad_rewarded_revive_earned',
          fields: {'amount': reward.amount, 'type': reward.type},
        );
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
          LoggingService.log('ad_rewarded_daily_loaded');
        },
        onAdFailedToLoad: (err) {
          _rewardedDaily = null;
          _log('rewarded daily failed: ${err.message}');
          LoggingService.log(
            'ad_rewarded_daily_failed_load',
            fields: {'code': err.code, 'message': err.message},
          );
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
    LoggingService.log('ad_rewarded_daily_show');
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _log('rewarded daily dismissed');
        LoggingService.log('ad_rewarded_daily_dismissed');
        ad.dispose();
        _rewardedDaily = null;
        preloadRewardedDailyReward();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        _log('rewarded daily failed to show: ${err.message}');
        LoggingService.log(
          'ad_rewarded_daily_failed_show',
          fields: {'code': err.code, 'message': err.message},
        );
        ad.dispose();
        _rewardedDaily = null;
        rewarded = false;
        preloadRewardedDailyReward();
      },
    );
    await ad.show(
      onUserEarnedReward: (ad, reward) {
        _log('rewarded daily earned: ${reward.amount} ${reward.type}');
        LoggingService.log(
          'ad_rewarded_daily_earned',
          fields: {'amount': reward.amount, 'type': reward.type},
        );
        rewarded = true;
      },
    );
    return rewarded;
  }

  /// Mendapatkan unit ID interstitial untuk platform saat ini (test IDs).
  String _interstitialUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _interstitialAndroidEnv;
      case TargetPlatform.iOS:
        return _interstitialIosEnv;
      default:
        return '';
    }
  }

  /// Mendapatkan unit ID rewarded untuk platform saat ini (test IDs).
  String _rewardedUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _rewardedAndroidEnv;
      case TargetPlatform.iOS:
        return _rewardedIosEnv;
      default:
        return '';
    }
  }

  /// Mendapatkan unit ID banner untuk platform saat ini (test IDs).
  String bannerUnitId() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _bannerAndroidEnv;
      case TargetPlatform.iOS:
        return _bannerIosEnv;
      default:
        return '';
    }
  }

  /// Utilitas untuk memeriksa batasan cooldown interstitial.
  /// Mengizinkan jika `last == null` atau selisih waktu >= `cooldown`.
  @visibleForTesting
  static bool cooldownAllows(DateTime? last, DateTime now, Duration cooldown) {
    // Mengizinkan bila belum pernah tampil atau jarak waktu >= cooldown
    if (last == null) return true;
    return now.difference(last) >= cooldown;
  }
}
