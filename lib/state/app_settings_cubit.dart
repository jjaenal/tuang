import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  AppSettingsCubit()
      : super(const AppSettingsState(
          audioOn: true,
          consentGiven: false,
          adsEnabled: false,
          paused: false,
        ));

  /// Toggle audio aktif/nonaktif.
  void toggleAudio() => emit(state.copyWith(audioOn: !state.audioOn));

  /// Set consent (GDPR/CCPA). Biasanya true setelah user menerima dialog consent.
  void setConsent(bool given) => emit(state.copyWith(consentGiven: given));

  /// Toggle iklan aktif/nonaktif. Disarankan hanya mengaktifkan jika consent sudah diberikan.
  void toggleAds() {
    final enable = !state.adsEnabled;
    // Jika ingin memaksa consent sebelum enable, UI akan menangani prompt.
    emit(state.copyWith(adsEnabled: enable));
  }

  /// Set pause/resume status dari UI overlay.
  void setPaused(bool paused) => emit(state.copyWith(paused: paused));
}