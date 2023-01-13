import 'package:google_mobile_ads/google_mobile_ads.dart';

final String appId = 'ca-app-pub-5879375763685096~3909542731';

final String bannerAdUnitId = 'ca-app-pub-5879375763685096/8970297720';
final String interstitialAdUnitId = 'ca-app-pub-5879375763685096/1749923722';
// final String nativeAdUnitId = 'ca-app-pub-5879375763685096/3147125403';
final AdRequest request = AdRequest(
  keywords: <String>['foo', 'bar'],
  contentUrl: 'http://foo.com/bar.html',
  nonPersonalizedAds: true,
);

int numInterstitialLoadAttempts = 0;
