import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../controllers/native_ad_controller.dart';
import 'config.dart';
import 'my_dialogs.dart';

class AdHelper {
  // Initialize Google Mobile Ads SDK
  static Future<void> initAds() async {
    await MobileAds.instance.initialize();
  }

  static InterstitialAd? _interstitialAd;
  static bool _interstitialAdLoaded = false;

  static NativeAd? _nativeAd;
  static bool _nativeAdLoaded = false;

  //*****************Interstitial Ad******************

  static void precacheInterstitialAd() {
    log('Precache Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) return;

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          // Ad listener
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              _resetInterstitialAd();
              precacheInterstitialAd(); // Load next ad
            },
          );
          _interstitialAd = ad;
          _interstitialAdLoaded = true;
        },
        onAdFailedToLoad: (err) {
          _resetInterstitialAd();
          log('Failed to load an interstitial ad: ${err.message}');
        },
      ),
    );
  }

  static void _resetInterstitialAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _interstitialAdLoaded = false;
  }

  static void showInterstitialAd({required VoidCallback onComplete}) {
    log('Showing Interstitial Ad - Id: ${Config.interstitialAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    if (_interstitialAdLoaded && _interstitialAd != null) {
      _interstitialAd?.show();
      onComplete();
      return;
    }

    // Show progress dialog while loading ad
    MyDialogs.showProgress();

    InterstitialAd.load(
      adUnitId: Config.interstitialAd,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back(); // Close the loading dialog
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              onComplete();
              _resetInterstitialAd();
              precacheInterstitialAd();
            },
          );
          ad.show();
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load an interstitial ad: ${err.message}');
          onComplete();
        },
      ),
    );
  }

  //*****************Native Ad******************

  static void precacheNativeAd() {
    log('Precache Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return;

    _nativeAd = NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('Native Ad loaded.');
          _nativeAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd();
          log('Native Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.small),
    )..load();
  }

  static void _resetNativeAd() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _nativeAdLoaded = false;
  }

  static NativeAd? loadNativeAd({required NativeAdController adController}) {
    log('Loading Native Ad - Id: ${Config.nativeAd}');

    if (Config.hideAds) return null;

    if (_nativeAdLoaded && _nativeAd != null) {
      adController.adLoaded.value = true;
      return _nativeAd;
    }

    return NativeAd(
      adUnitId: Config.nativeAd,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          log('Native Ad loaded.');
          adController.adLoaded.value = true;
          _resetNativeAd();
          precacheNativeAd(); // Precache next native ad
        },
        onAdFailedToLoad: (ad, error) {
          _resetNativeAd();
          log('Native Ad failed to load: $error');
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.small),
    )..load();
  }

  //*****************Rewarded Ad******************

  static void showRewardedAd({required VoidCallback onComplete}) {
    log('Rewarded Ad Id: ${Config.rewardedAd}');

    if (Config.hideAds) {
      onComplete();
      return;
    }

    MyDialogs.showProgress();

    RewardedAd.load(
      adUnitId: Config.rewardedAd,
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          Get.back(); // Close the loading dialog

          // Reward listener
          ad.show(onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            onComplete();
          });
        },
        onAdFailedToLoad: (err) {
          Get.back();
          log('Failed to load a rewarded ad: ${err.message}');
          // Optionally call onComplete if you don't want to block on failure
          onComplete();
        },
      ),
    );
  }
}
