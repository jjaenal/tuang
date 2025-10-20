/// Centralized SharedPreferences keys to avoid string duplication across modules.
class PrefKeys {
  static const String audioOn = 'pref_audioOn';
  static const String hapticsOn = 'pref_hapticsOn';
  static const String consentGiven = 'pref_consentGiven';
  static const String adsEnabled = 'pref_adsEnabled';
  static const String paused = 'pref_paused';

  static const String lastDailyRewardDate = 'pref_lastDailyRewardDate';
  static const String coins = 'pref_coins';
  static const String npaEnabled = 'pref_npaEnabled';

  // Magnet-related keys
  static const String pendingMagnetBuffSec = 'pref_pendingMagnetBuffSec';
  static const String dailyMagnetBuffSec = 'pref_dailyMagnetBuffSec';
}
