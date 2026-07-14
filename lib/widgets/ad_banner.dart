import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

// Renders nothing until the ad loads (or forever, if it fails), so it never
// reserves blank space at the bottom of a screen. google_mobile_ads has no
// web implementation, so this is a no-op there rather than throwing.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _bannerAd = AdService.createBanner(
        onLoaded: () {
          if (mounted) setState(() => _isLoaded = true);
        },
      );
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bannerAd = _bannerAd;
    if (bannerAd == null || !_isLoaded) return const SizedBox.shrink();
    return SafeArea(
      child: SizedBox(
        width: bannerAd.size.width.toDouble(),
        height: bannerAd.size.height.toDouble(),
        child: AdWidget(ad: bannerAd),
      ),
    );
  }
}
