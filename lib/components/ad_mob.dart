import 'package:read_aloud/components/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MyAdManager {
  late BannerAd bannerAd1;
  late BannerAd bannerAd2;

  MyAdManager() {
    bannerAd1 = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId1, // 異なる広告ユニットID
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      request: AdRequest(),
    )..load();

    bannerAd2 = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId2, // 異なる広告ユニットID
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          ad.dispose();
        },
      ),
      request: AdRequest(),
    )..load();
  }
  void load() {
    bannerAd1.load();
    bannerAd2.load();
  }

  Widget getAdBanner1() {
    return Container(
        alignment: Alignment.center,
        width: bannerAd1.size.width.toDouble(),
        height: bannerAd1.size.height.toDouble(),
        child: AdWidget(ad: bannerAd1));
  }

  Widget getAdBanner2() {
    return Container(
        alignment: Alignment.center,
        width: bannerAd2.size.width.toDouble(),
        height: bannerAd2.size.height.toDouble(),
        child: AdWidget(ad: bannerAd2));
  }

  double getAdBannerHeight() {
    return bannerAd1.size.height.toDouble();
  }

  void dispose() {
    bannerAd1.dispose();
    bannerAd2.dispose();
  }
}
