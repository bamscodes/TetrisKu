import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:tetris/music_manager.dart';

class InterstitialAdWidget {
  InterstitialAd? _interstitialAd;

  /// Load iklan interstitial
  void loadAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-2144310268071555/5688428339', // ID AdMob
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Tampilkan iklan, lalu jalankan callback setelah iklan ditutup
  void showAd(Function onAdClosed) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          loadAd();
          MusicManager.reset(); // 🔊 Putar ulang musik menu
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          MusicManager.reset(); // 🔊 Putar ulang musik meski gagal tampil
          onAdClosed();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      MusicManager.reset(); // 🔊 Musik tetap diputar meski iklan belum siap
      onAdClosed();
    }
  }
}
