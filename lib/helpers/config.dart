import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

class Config {
  static final FirebaseRemoteConfig _config = FirebaseRemoteConfig.instance;

  static const Map<String, dynamic> _defaultValues = {
    "interstitial_ad": "ca-app-pub-3470860632886709/7411230622",
    "native_ad": "ca-app-pub-3470860632886709/5692753021",
    "rewarded_ad": "ca-app-pub-3940256099942544/5224354917",
    "show_ads": true,
  };

  // Initialize Remote Config and set default values
  static Future<void> initConfig() async {
    try {
      // Ensure Firebase is initialized
      await Firebase.initializeApp();

      await _config.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 30),
      ));

      await _config.setDefaults(_defaultValues);
      bool updated = await _config.fetchAndActivate();
      log('Remote Config Data (fetchAndActivate): ${_config.getBool('show_ads')}, Updated: $updated');

      // Listen for configuration updates
      _config.onConfigUpdated.listen((event) async {
        await _config.activate();
        log('Config Updated: ${_config.getBool('show_ads')}');
      });
    } catch (e) {
      log('Error initializing Remote Config: $e');
    }
  }

  // Getter for show_ads value
  static bool get _showAd => _config.getBool('show_ads');

  // Getters for ad unit IDs
  static String get nativeAd => _config.getString('native_ad');
  static String get interstitialAd => _config.getString('interstitial_ad');
  static String get rewardedAd => _config.getString('rewarded_ad');

  // Getter for determining whether to hide ads
  static bool get hideAds => !_showAd;
}
