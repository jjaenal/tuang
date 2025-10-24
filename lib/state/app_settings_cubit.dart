import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/character_skin.dart';
import '../game/game_config.dart';
import 'pref_keys.dart';
import '../models/difficulty.dart';

class AppSettingsState extends Equatable {
  final bool audioOn;
  final bool hapticsOn;
  final bool consentGiven;
  final bool adsEnabled;
  final bool paused;
  final int coins;
  final bool npaEnabled;
  final int dailyMagnetBuffSeconds;
  final int pendingMagnetBuffSeconds;
  final DateTime? lastDailyRewardClaimedAt;
  final String playerName;
  final String activeSkinId;
  final List<String> unlockedSkinIds;
  final Difficulty difficulty;
  final String languageCode;

  const AppSettingsState({
    this.audioOn = true,
    this.hapticsOn = true,
    this.consentGiven = false,
    this.adsEnabled = false,
    this.paused = false,
    this.coins = 0,
    this.npaEnabled = false,
    this.dailyMagnetBuffSeconds = GameConfig.defaultDailyMagnetBuffSec,
    this.pendingMagnetBuffSeconds = 0,
    this.lastDailyRewardClaimedAt,
    this.playerName = 'Player',
    this.activeSkinId = 'default',
    this.unlockedSkinIds = const ['default'],
    this.difficulty = Difficulty.normal,
    this.languageCode = 'id',
  });

  AppSettingsState copyWith({
    bool? audioOn,
    bool? hapticsOn,
    bool? consentGiven,
    bool? adsEnabled,
    bool? paused,
    int? coins,
    bool? npaEnabled,
    int? dailyMagnetBuffSeconds,
    int? pendingMagnetBuffSeconds,
    DateTime? lastDailyRewardClaimedAt,
    String? playerName,
    String? activeSkinId,
    List<String>? unlockedSkinIds,
    Difficulty? difficulty,
    String? languageCode,
  }) {
    return AppSettingsState(
      audioOn: audioOn ?? this.audioOn,
      hapticsOn: hapticsOn ?? this.hapticsOn,
      consentGiven: consentGiven ?? this.consentGiven,
      adsEnabled: adsEnabled ?? this.adsEnabled,
      paused: paused ?? this.paused,
      coins: coins ?? this.coins,
      npaEnabled: npaEnabled ?? this.npaEnabled,
      dailyMagnetBuffSeconds:
          dailyMagnetBuffSeconds ?? this.dailyMagnetBuffSeconds,
      pendingMagnetBuffSeconds:
          pendingMagnetBuffSeconds ?? this.pendingMagnetBuffSeconds,
      lastDailyRewardClaimedAt:
          lastDailyRewardClaimedAt ?? this.lastDailyRewardClaimedAt,
      playerName: playerName ?? this.playerName,
      activeSkinId: activeSkinId ?? this.activeSkinId,
      unlockedSkinIds: unlockedSkinIds ?? this.unlockedSkinIds,
      difficulty: difficulty ?? this.difficulty,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
    audioOn,
    hapticsOn,
    consentGiven,
    adsEnabled,
    paused,
    coins,
    npaEnabled,
    dailyMagnetBuffSeconds,
    pendingMagnetBuffSeconds,
    lastDailyRewardClaimedAt,
    playerName,
    activeSkinId,
    unlockedSkinIds,
    difficulty,
    languageCode,
  ];

  bool get canClaimDailyReward {
    if (lastDailyRewardClaimedAt == null) return true;
    final now = DateTime.now();
    final diff = now.difference(lastDailyRewardClaimedAt!);
    return diff.inHours >= 24;
  }
}

class AppSettingsCubit extends Cubit<AppSettingsState> {
  AppSettingsCubit() : super(const AppSettingsState());

  // Provide forwards for tests that reference via cubit
  static const int defaultDailyMagnetBuffSec =
      GameConfig.defaultDailyMagnetBuffSec;
  static const int maxDailyMagnetBuffSec = GameConfig.maxDailyMagnetBuffSec;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final audioOn = prefs.getBool(PrefKeys.audioOn) ?? state.audioOn;
    final hapticsOn = prefs.getBool(PrefKeys.hapticsOn) ?? state.hapticsOn;
    final consentGiven =
        prefs.getBool(PrefKeys.consentGiven) ?? state.consentGiven;
    final adsEnabled = prefs.getBool(PrefKeys.adsEnabled) ?? state.adsEnabled;
    final paused = prefs.getBool(PrefKeys.paused) ?? state.paused;
    final coins = prefs.getInt(PrefKeys.coins) ?? state.coins;
    final npaEnabled = prefs.getBool(PrefKeys.npaEnabled) ?? state.npaEnabled;
    final dailyMagnetBuffSec =
        prefs.getInt(PrefKeys.dailyMagnetBuffSec) ??
        state.dailyMagnetBuffSeconds;
    final pendingMagnetBuffSec =
        prefs.getInt(PrefKeys.pendingMagnetBuffSec) ??
        state.pendingMagnetBuffSeconds;
    final lastRewardStr = prefs.getString(PrefKeys.lastDailyRewardDate);
    final playerName = prefs.getString(PrefKeys.playerName) ?? state.playerName;
    final activeSkinId =
        prefs.getString(PrefKeys.activeSkinId) ?? state.activeSkinId;
    final unlockedSkinIds =
        prefs.getStringList(PrefKeys.unlockedSkinIds) ?? state.unlockedSkinIds;
    final difficultyKey = prefs.getString(PrefKeys.difficulty);
    final languageCode =
        prefs.getString(PrefKeys.languageCode) ?? state.languageCode;

    emit(
      state.copyWith(
        audioOn: audioOn,
        hapticsOn: hapticsOn,
        consentGiven: consentGiven,
        adsEnabled: adsEnabled,
        paused: paused,
        coins: coins,
        npaEnabled: npaEnabled,
        dailyMagnetBuffSeconds: dailyMagnetBuffSec,
        pendingMagnetBuffSeconds: pendingMagnetBuffSec,
        lastDailyRewardClaimedAt:
            lastRewardStr == null ? null : DateTime.tryParse(lastRewardStr),
        playerName: playerName,
        activeSkinId: activeSkinId,
        unlockedSkinIds: unlockedSkinIds,
        difficulty: DifficultyX.fromKey(difficultyKey),
        languageCode: languageCode,
      ),
    );
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefKeys.audioOn, state.audioOn);
    await prefs.setBool(PrefKeys.hapticsOn, state.hapticsOn);
    await prefs.setBool(PrefKeys.consentGiven, state.consentGiven);
    await prefs.setBool(PrefKeys.adsEnabled, state.adsEnabled);
    await prefs.setBool(PrefKeys.paused, state.paused);
    await prefs.setInt(PrefKeys.coins, state.coins);
    await prefs.setBool(PrefKeys.npaEnabled, state.npaEnabled);
    await prefs.setInt(
      PrefKeys.dailyMagnetBuffSec,
      state.dailyMagnetBuffSeconds,
    );
    await prefs.setInt(
      PrefKeys.pendingMagnetBuffSec,
      state.pendingMagnetBuffSeconds,
    );
    await prefs.setString(PrefKeys.playerName, state.playerName);
    await prefs.setString(PrefKeys.activeSkinId, state.activeSkinId);
    await prefs.setStringList(PrefKeys.unlockedSkinIds, state.unlockedSkinIds);
    await prefs.setString(PrefKeys.difficulty, state.difficulty.key);
    await prefs.setString(PrefKeys.languageCode, state.languageCode);

    if (state.lastDailyRewardClaimedAt != null) {
      await prefs.setString(
        PrefKeys.lastDailyRewardDate,
        state.lastDailyRewardClaimedAt!.toIso8601String(),
      );
    }
  }

  void toggleAudio() {
    emit(state.copyWith(audioOn: !state.audioOn));
    _savePrefs();
  }

  void toggleHaptics() {
    emit(state.copyWith(hapticsOn: !state.hapticsOn));
    _savePrefs();
  }

  void setConsent(bool value) {
    emit(state.copyWith(consentGiven: value));
    _savePrefs();
  }

  void setPlayerName(String name) {
    if (name.isNotEmpty) {
      emit(state.copyWith(playerName: name));
      _savePrefs();
    }
  }

  void toggleAds() {
    emit(state.copyWith(adsEnabled: !state.adsEnabled));
    _savePrefs();
  }

  void setPaused(bool value) {
    emit(state.copyWith(paused: value));
    _savePrefs();
  }

  void toggleNpa() {
    emit(state.copyWith(npaEnabled: !state.npaEnabled));
    _savePrefs();
  }

  void setDailyMagnetBuffSeconds(int seconds) {
    final clamped = seconds.clamp(0, GameConfig.maxDailyMagnetBuffSec);
    emit(state.copyWith(dailyMagnetBuffSeconds: clamped));
    _savePrefs();
  }

  void grantMagnetBuff(int seconds) {
    final clamped = seconds.clamp(0, GameConfig.maxDailyMagnetBuffSec);
    emit(state.copyWith(pendingMagnetBuffSeconds: clamped));
    _savePrefs();
  }

  int consumeMagnetBuff() {
    final s = state.pendingMagnetBuffSeconds;
    emit(state.copyWith(pendingMagnetBuffSeconds: 0));
    _savePrefs();
    return s;
  }

  bool get canClaimDailyReward => state.canClaimDailyReward;

  void markDailyRewardClaimedNow() {
    emit(state.copyWith(lastDailyRewardClaimedAt: DateTime.now()));
    _savePrefs();
  }

  void addCoins(int amount) {
    if (amount <= 0) return;
    emit(state.copyWith(coins: state.coins + amount));
    _savePrefs();
  }

  bool spendCoins(int amount) {
    if (amount <= 0) return true;
    if (state.coins < amount) return false;
    emit(state.copyWith(coins: state.coins - amount));
    _savePrefs();
    return true;
  }

  void setDifficulty(Difficulty value) {
    emit(state.copyWith(difficulty: value));
    _savePrefs();
  }

  void setLanguageCode(String code) {
    if (code.isEmpty) return;
    emit(state.copyWith(languageCode: code));
    _savePrefs();
  }

  // === Skins API ===
  List<CharacterSkin> getAllSkins() {
    final unlocked = state.unlockedSkinIds.toSet();
    return CharacterSkin.defaultSkins
        .map(
          (s) =>
              s.copyWith(isUnlocked: unlocked.contains(s.id) || (s.price == 0)),
        )
        .toList();
  }

  CharacterSkin getActiveSkin() {
    final all = getAllSkins();
    return all.firstWhere(
      (s) => s.id == state.activeSkinId,
      orElse: () => all.first,
    );
  }

  bool isSkinUnlocked(String id) {
    return state.unlockedSkinIds.contains(id);
  }

  void unlockSkin(String id) {
    if (isSkinUnlocked(id)) return;
    final next = List<String>.from(state.unlockedSkinIds)..add(id);
    emit(state.copyWith(unlockedSkinIds: next));
    _savePrefs();
  }

  bool purchaseSkin(String id) {
    if (isSkinUnlocked(id)) return true;
    final skin = CharacterSkin.defaultSkins.firstWhere(
      (s) => s.id == id,
      orElse:
          () => CharacterSkin(
            id: 'invalid',
            name: 'Invalid',
            color: Colors.grey,
            price: 0,
          ),
    );
    if (skin.id == 'invalid') return false;
    if (!spendCoins(skin.price)) return false;
    unlockSkin(id);
    return true;
  }

  void setActiveSkin(String id) {
    // Only allow selecting unlocked skins
    if (!isSkinUnlocked(id)) return;
    emit(state.copyWith(activeSkinId: id));
    _savePrefs();
  }
}
