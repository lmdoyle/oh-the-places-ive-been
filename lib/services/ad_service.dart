import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Google's official test ad unit IDs. Swap for real ones once the AdMob
  // app is registered — see the "next steps" note in the project README.
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _interstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';

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

  static InterstitialAd? _interstitial;

  static Future<void> loadInterstitial() async {
    await InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitial = ad,
        onAdFailedToLoad: (_) => _interstitial = null,
      ),
    );
  }

  static Future<void> showInterstitial() async {
    if (_interstitial != null) {
      await _interstitial!.show();
      _interstitial = null;
    }
    loadInterstitial();
  }
}
