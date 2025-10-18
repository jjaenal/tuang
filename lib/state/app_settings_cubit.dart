import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppSettingsCubit mengelola state non-game (UI/app-layer) seperti:
/// - audioOn: apakah audio diaktifkan
/// - consentGiven: apakah user telah memberikan consent (GDPR/CCPA)
/// - adsEnabled: apakah iklan diaktifkan (hanya jika consent diberikan)
/// - paused: apakah game sedang dipause (mengendalikan pause/resume dari UI)
class AppSettingsState extends Equatable {
  final bool audioOn;
  final bool consentGiven;
  final bool adsEnabled;
  final bool paused;

  const AppSettingsState({
    required this.audioOn,
    required this.consentGiven,
    required this.adsEnabled,
    required this.paused,
  });

  AppSettingsState copyWith({
    bool? audioOn,
    bool? consentGiven,
    bool? adsEnabled,
    bool? paused,
  }) {
    return AppSettingsState(
      audioOn: audioOn ?? this.audioOn,
      consentGiven: consentGiven ?? this.consentGiven,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      paused: paused ?? this.paused,
    );
  }

  @override
  List<Object?> get props => [audioOn, consentGiven, adsEnabled, paused];
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  static const _kAudioOn = 'pref_audioOn';
  static const _kConsentGiven = 'pref_consentGiven';
  static const _kAdsEnabled = 'pref_adsEnabled';
  static const _kPaused = 'pref_paused';

  AppSettingsCubit()
      : super(const AppSettingsState(
          audioOn: true,
          consentGiven: false,
          adsEnabled: false,
          paused: false,
        ));

  /// Muat state dari SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    emit(AppSettingsState(
      audioOn: prefs.getBool(_kAudioOn) ?? state.audioOn,
      consentGiven: prefs.getBool(_kConsentGiven) ?? state.consentGiven,
      adsEnabled: prefs.getBool(_kAdsEnabled) ?? state.adsEnabled,
      paused: prefs.getBool(_kPaused) ?? state.paused,
    ));
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAudioOn, state.audioOn);
    await prefs.setBool(_kConsentGiven, state.consentGiven);
    await prefs.setBool(_kAdsEnabled, state.adsEnabled);
    await prefs.setBool(_kPaused, state.paused);
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

  /// Set pause/resume status dari UI overlay.
  void setPaused(bool paused) {
    emit(state.copyWith(paused: paused));
    _savePrefs();
  }
}