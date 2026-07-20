import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static const String _bannerAdUnitId =
      'ca-app-pub-3997989080158685/5812164643';

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
