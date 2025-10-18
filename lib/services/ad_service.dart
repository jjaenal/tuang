import 'package:flutter/foundation.dart';

class AdService {
  static final AdService I = AdService._();
  AdService._();

  Future<void> init() async {
    if (kIsWeb) return; // ads fokus Android/iOS
    // TODO: Inisialisasi Google Mobile Ads SDK
  }

  Future<bool> showInterstitial() async {
    if (kIsWeb) return false;
    // TODO: Load & tampilkan interstitial
    return false;
  }

  Future<bool> showRewardedRevive() async {
    if (kIsWeb) return false;
    // TODO: Load & tampilkan rewarded (revive)
    return false;
  }
}