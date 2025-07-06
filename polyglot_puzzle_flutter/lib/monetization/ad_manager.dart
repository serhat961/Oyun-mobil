import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdManager {
  static final AdManager instance = AdManager._internal();
  DateTime _lastInterstitial = DateTime.fromMillisecondsSinceEpoch(0);
  InterstitialAd? _cachedInterstitial;

  AdManager._internal();

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    _cacheInterstitial();
  }

  /// Banner ad widget (test ID)
  BannerAd createBannerAd() {
    return BannerAd(
      size: AdSize.banner,
      adUnitId: _bannerUnitId,
      listener: const BannerAdListener(),
      request: const AdRequest(),
    )..load();
  }

  Future<bool> showInterstitial({required VoidCallback onShown, required VoidCallback onFailed}) async {
    final now = DateTime.now();
    if (now.difference(_lastInterstitial).inMinutes < 5) return false;

    if (_cachedInterstitial == null) {
      onFailed();
      return false;
    }
    _cachedInterstitial!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastInterstitial = DateTime.now();
        ad.dispose();
        _cacheInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('Interstitial failed: $error');
        ad.dispose();
        _cacheInterstitial();
        onFailed();
      },
    );
    _cachedInterstitial!.show();
    _cachedInterstitial = null;
    onShown();
    return true;
  }

  void _cacheInterstitial() {
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _cachedInterstitial = ad,
        onAdFailedToLoad: (error) => debugPrint('Interstitial load error: $error'),
      ),
    );
  }

  Future<RewardedAd?> loadRewardedAd() async {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => completer.complete(ad),
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded load error: $error');
          completer.complete(null);
        },
      ),
    );
    return completer.future;
  }

  static const String _bannerUnitId = 'ca-app-pub-3940256099942544/6300978111'; // test
  static const String _interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712'; // test
  static const String _rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917'; // test
}