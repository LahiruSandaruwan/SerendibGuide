import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/constants.dart';

/// Service for managing AdMob advertisements
class AdMobService {
  static int _interstitialAttempts = 0;

  /// Get banner ad unit ID for current platform
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.bannerAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.bannerAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Get interstitial ad unit ID for current platform
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return AppConstants.interstitialAdUnitIdAndroid;
    } else if (Platform.isIOS) {
      return AppConstants.interstitialAdUnitIdIOS;
    }
    throw UnsupportedError('Unsupported platform');
  }

  /// Create and load banner ad
  static Future<BannerAd?> createBannerAd() async {
    try {
      final BannerAd banner = BannerAd(
        adUnitId: bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('✓ Banner ad loaded successfully');
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('✗ Banner ad failed to load: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) {
            print('Banner ad opened');
          },
          onAdClosed: (Ad ad) {
            print('Banner ad closed');
          },
        ),
      );

      await banner.load();
      return banner;
    } catch (e) {
      print('✗ Error creating banner ad: $e');
      return null;
    }
  }

  /// Load interstitial ad
  static Future<InterstitialAd?> loadInterstitialAd() async {
    if (_interstitialAttempts >= AppConstants.interstitialAdMaxAttempts) {
      print('✗ Max interstitial ad attempts reached');
      _interstitialAttempts = 0;
      return null;
    }

    _interstitialAttempts++;

    try {
      InterstitialAd? interstitialAd;

      await InterstitialAd.load(
        adUnitId: interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('✓ Interstitial ad loaded successfully');
            interstitialAd = ad;
            _interstitialAttempts = 0; // Reset on success

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (InterstitialAd ad) {
                print('Interstitial ad showed full screen');
              },
              onAdDismissedFullScreenContent: (InterstitialAd ad) {
                print('Interstitial ad dismissed');
                ad.dispose();
              },
              onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
                print('✗ Interstitial ad failed to show: $error');
                ad.dispose();
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('✗ Interstitial ad failed to load: $error');
            interstitialAd = null;
          },
        ),
      );

      // Wait a bit for the ad to load
      await Future.delayed(const Duration(seconds: 2));
      return interstitialAd;
    } catch (e) {
      print('✗ Error loading interstitial ad: $e');
      return null;
    }
  }

  /// Show interstitial ad
  static Future<bool> showInterstitialAd(InterstitialAd? ad) async {
    if (ad == null) {
      print('✗ Cannot show null interstitial ad');
      return false;
    }

    try {
      await ad.show();
      return true;
    } catch (e) {
      print('✗ Error showing interstitial ad: $e');
      ad.dispose();
      return false;
    }
  }

  /// Load and show interstitial ad (convenience method)
  static Future<bool> loadAndShowInterstitial() async {
    print('Loading interstitial ad...');
    final InterstitialAd? ad = await loadInterstitialAd();

    if (ad != null) {
      // Add a small delay to avoid disrupting user experience
      await Future.delayed(const Duration(seconds: 1));
      return await showInterstitialAd(ad);
    }

    return false;
  }

  /// Initialize AdMob (call in main())
  static Future<void> initialize() async {
    try {
      await MobileAds.instance.initialize();
      print('✓ AdMob initialized successfully');

      // Configure request configuration for testing (debug mode only)
      // Uncomment and add your test device IDs during development
      // final RequestConfiguration requestConfiguration = RequestConfiguration(
      //   testDeviceIds: ['YOUR_TEST_DEVICE_ID'],
      // );
      // MobileAds.instance.updateRequestConfiguration(requestConfiguration);
    } catch (e) {
      print('✗ Error initializing AdMob: $e');
    }
  }

  /// Dispose banner ad
  static void disposeBanner(BannerAd? ad) {
    ad?.dispose();
  }

  /// Dispose interstitial ad
  static void disposeInterstitial(InterstitialAd? ad) {
    ad?.dispose();
  }

  /// Reset interstitial attempt counter
  static void resetInterstitialAttempts() {
    _interstitialAttempts = 0;
  }
}
