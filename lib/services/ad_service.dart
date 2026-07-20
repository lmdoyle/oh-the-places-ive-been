import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Google's official test ad unit ID. Swap for the real one once the
  // AdMob app is registered.
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  static BannerAd createBanner({
    void Function()? onLoaded,
    void Function()? onFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => onLoaded?.call(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailedToLoad?.call();
        },
      ),
    )..load();
  }
}
