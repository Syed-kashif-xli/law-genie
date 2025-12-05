import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test Ad Unit IDs
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-3940256099942544/6300978111';
      // Real ID: 'ca-app-pub-9032147226605088/9483490380'
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      // Test ID
      return 'ca-app-pub-3940256099942544/5224354917';
      // Real ID: 'ca-app-pub-9032147226605088/4762085089'
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // Test ID
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  static BannerAd createBannerAd({required Function(Ad) onAdLoaded}) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );
  }

  static void showRewardedAd({
    required VoidCallback onUserEarnedReward,
    VoidCallback? onAdFailedToLoad,
  }) {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
              onUserEarnedReward();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          if (onAdFailedToLoad != null) {
            onAdFailedToLoad();
          } else {
            // If ad fails, just grant reward to avoid blocking user
            onUserEarnedReward();
          }
        },
      ),
    );
  }
}
