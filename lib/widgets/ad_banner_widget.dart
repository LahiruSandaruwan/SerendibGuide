import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/admob_service.dart';
import '../utils/constants.dart';

/// Widget to display AdMob banner ads (only for free users)
class AdBannerWidget extends StatefulWidget {
  const AdBannerWidget({super.key});

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  Future<void> _loadAd() async {
    final appState = context.read<AppStateProvider>();

    // Don't load ads for premium users
    if (appState.isPremium) return;

    final BannerAd? ad = await AdMobService.createBannerAd();

    if (ad != null && mounted) {
      setState(() {
        _bannerAd = ad;
        _isAdLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    // Don't show ads for premium users
    if (appState.isPremium) {
      return const SizedBox.shrink();
    }

    // Show ad if loaded
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        color: Colors.grey[200],
        width: double.infinity,
        height: AppConstants.bannerAdHeight,
        child: AdWidget(ad: _bannerAd!),
      );
    }

    // Show placeholder while loading
    return Container(
      color: Colors.grey[100],
      width: double.infinity,
      height: AppConstants.bannerAdHeight,
      child: Center(
        child: Text(
          'Advertisement',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
