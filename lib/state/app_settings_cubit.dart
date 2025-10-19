import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSettingsCubit mengelola state non-game (UI/app-layer) seperti:
/// - audioOn: apakah audio diaktifkan
/// - consentGiven: apakah user telah memberikan consent (GDPR/CCPA)
/// - adsEnabled: apakah iklan diaktifkan (hanya jika consent diberikan)
/// - paused: apakah game sedang dipause (mengendalikan pause/resume dari UI)
/// - lastDailyRewardDate: tanggal terakhir daily reward diklaim (format YYYY-MM-DD, lokal)
class AppSettingsState extends Equatable {
  final bool audioOn;
  final bool consentGiven;
  final bool adsEnabled;
  final bool paused;
  
  /// Menyimpan tanggal lokal (YYYY-MM-DD) kapan daily reward terakhir diklaim.
  /// Null jika belum pernah diklaim.
  final String? lastDailyRewardDate;
  
  /// Saldo coins (mata uang in-game) yang persisten.
  final int coins;
  
  /// Preferensi Non-Personalized Ads (GDPR/privasi). Jika true, minta NPA.
  final bool npaEnabled;
  
  /// Buff magnet yang pending (detik) akan diterapkan saat game dimulai, lalu direset.
  final int pendingMagnetBuffSeconds;

  const AppSettingsState({
    required this.audioOn,
    required this.consentGiven,
    required this.adsEnabled,
    required this.paused,
    // Tambahan field untuk persist daily reward.
    this.lastDailyRewardDate,
    // Default coins 0 jika belum ada.
    this.coins = 0,
    // Default NPA off.
    this.npaEnabled = false,
    // Default tidak ada buff magnet.
    this.pendingMagnetBuffSeconds = 0,
  });

  AppSettingsState copyWith({
    bool? audioOn,
    bool? consentGiven,
    bool? adsEnabled,
    bool? paused,
    // Mengizinkan update tanggal daily reward.
    String? lastDailyRewardDate,
    int? coins,
    bool? npaEnabled,
    int? pendingMagnetBuffSeconds,
  }) {
    return AppSettingsState(
      audioOn: audioOn ?? this.audioOn,
      consentGiven: consentGiven ?? this.consentGiven,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      paused: paused ?? this.paused,
      lastDailyRewardDate: lastDailyRewardDate ?? this.lastDailyRewardDate,
      coins: coins ?? this.coins,
      npaEnabled: npaEnabled ?? this.npaEnabled,
      pendingMagnetBuffSeconds: pendingMagnetBuffSeconds ?? this.pendingMagnetBuffSeconds,
    );
  }

  @override
  List<Object?> get props => [audioOn, consentGiven, adsEnabled, paused, lastDailyRewardDate, coins, npaEnabled, pendingMagnetBuffSeconds];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  static const _kAudioOn = 'pref_audioOn';
  static const _kConsentGiven = 'pref_consentGiven';
  static const _kAdsEnabled = 'pref_adsEnabled';
  static const _kPaused = 'pref_paused';
  // Key baru untuk menyimpan tanggal terakhir daily reward diklaim.
  static const _kLastDailyRewardDate = 'pref_lastDailyRewardDate';
  // Key untuk saldo coins persisten.
  static const _kCoins = 'pref_coins';
  // Key untuk Non-Personalized Ads.
  static const _kNpaEnabled = 'pref_npaEnabled';
  // Key untuk buff magnet pending.
  static const _kPendingMagnetBuffSec = 'pref_pendingMagnetBuffSec';

  AppSettingsCubit()
      : super(const AppSettingsState(
          audioOn: true,
          consentGiven: false,
          adsEnabled: false,
          paused: false,
          // lastDailyRewardDate default null (belum diklaim).
          // coins default 0.
          // npaEnabled default false.
        ));

  /// Muat state dari SharedPreferences.
  /// Termasuk tanggal terakhir daily reward diklaim jika ada.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(AppSettingsState(
      audioOn: prefs.getBool(_kAudioOn) ?? state.audioOn,
      consentGiven: prefs.getBool(_kConsentGiven) ?? state.consentGiven,
      adsEnabled: prefs.getBool(_kAdsEnabled) ?? state.adsEnabled,
      paused: prefs.getBool(_kPaused) ?? state.paused,
      lastDailyRewardDate: prefs.getString(_kLastDailyRewardDate) ?? state.lastDailyRewardDate,
      coins: prefs.getInt(_kCoins) ?? state.coins,
      npaEnabled: prefs.getBool(_kNpaEnabled) ?? state.npaEnabled,
      pendingMagnetBuffSeconds: prefs.getInt(_kPendingMagnetBuffSec) ?? state.pendingMagnetBuffSeconds,
    ));
  }

  /// Simpan state ke SharedPreferences.
  /// Jika lastDailyRewardDate null, key akan dihapus.
  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAudioOn, state.audioOn);
    await prefs.setBool(_kConsentGiven, state.consentGiven);
    await prefs.setBool(_kAdsEnabled, state.adsEnabled);
    await prefs.setBool(_kPaused, state.paused);
    final lastDate = state.lastDailyRewardDate;
    if (lastDate == null) {
      await prefs.remove(_kLastDailyRewardDate);
    } else {
      await prefs.setString(_kLastDailyRewardDate, lastDate);
    }
    await prefs.setInt(_kCoins, state.coins);
    await prefs.setBool(_kNpaEnabled, state.npaEnabled);
    await prefs.setInt(_kPendingMagnetBuffSec, state.pendingMagnetBuffSeconds);
  }

  /// Toggle audio aktif/nonaktif.
  void toggleAudio() {
    emit(state.copyWith(audioOn: !state.audioOn));
    _savePrefs();
  }

  /// Set consent (GDPR/CCPA). Biasanya true setelah user menerima dialog consent.
  void setConsent(bool given) {
    emit(state.copyWith(consentGiven: given));
    _savePrefs();
  }

  /// Toggle iklan aktif/nonaktif. Disarankan hanya mengaktifkan jika consent sudah diberikan.
  void toggleAds() {
    final enable = !state.adsEnabled;
    emit(state.copyWith(adsEnabled: enable));
    _savePrefs();
  }

  /// Toggle Non-Personalized Ads (NPA).
  void toggleNpa() {
    emit(state.copyWith(npaEnabled: !state.npaEnabled));
    _savePrefs();
  }

  /// Grant buff magnet (detik) untuk diaplikasikan saat game dimulai.
  void grantMagnetBuff(int seconds) {
    if (seconds <= 0) return;
    emit(state.copyWith(pendingMagnetBuffSeconds: seconds));
    _savePrefs();
  }

  /// Konsumsi buff magnet: kembalikan durasi dan reset ke 0.
  int consumeMagnetBuff() {
    final s = state.pendingMagnetBuffSeconds;
    if (s > 0) {
      emit(state.copyWith(pendingMagnetBuffSeconds: 0));
      _savePrefs();
    }
    return s;
  }

  /// Set pause/resume status dari UI overlay.
  void setPaused(bool paused) {
    emit(state.copyWith(paused: paused));
    _savePrefs();
  }

  /// Utility: kembalikan string tanggal lokal "YYYY-MM-DD" (tanpa jam) untuk perbandingan harian.
  String _todayDateString() {
    final now = DateTime.now().toLocal();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Getter: apakah pengguna bisa klaim daily reward hari ini.
  /// True jika belum ada klaim pada tanggal hari ini.
  bool get canClaimDailyReward {
    final today = _todayDateString();
    return state.lastDailyRewardDate != today;
  }

  /// Tambah coins ke saldo dan simpan.
  void addCoins(int amount) {
    if (amount <= 0) return;
    final next = state.coins + amount;
    emit(state.copyWith(coins: next));
    _savePrefs();
  }

  /// Coba kurangi coins dari saldo. Mengembalikan true jika berhasil.
  bool spendCoins(int amount) {
    if (amount <= 0) return false;
    if (state.coins < amount) return false;
    final next = state.coins - amount;
    emit(state.copyWith(coins: next));
    _savePrefs();
    return true;
  }

  /// Tandai bahwa pengguna telah mengklaim daily reward pada tanggal hari ini.
  /// Menyimpan tanggal klaim ke SharedPreferences.
  void markDailyRewardClaimedNow() {
    final today = _todayDateString();
    emit(state.copyWith(lastDailyRewardDate: today));
    _savePrefs();
  }
}