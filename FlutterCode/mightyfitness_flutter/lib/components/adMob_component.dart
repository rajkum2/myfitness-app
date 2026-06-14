import '../utils/shared_import.dart';

InterstitialAd? interstitialAd;
bool? adClosed;

adShow() async {
  if (interstitialAd == null) {
    print('Warning: attempt to show interstitial before loaded.');
    return;
  }
  interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
    onAdShowedFullScreenContent: (InterstitialAd ad) =>
        print('ad onAdShowedFullScreenContent.'),
    onAdDismissedFullScreenContent: (InterstitialAd ad) {
      print('$ad onAdDismissedFullScreenContent.');
      adClosed = true;
      ad.dispose();
    },
    onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
      print('$ad onAdFailedToShowFullScreenContent: $error');
      ad.dispose();
      createInterstitialAd();
    },
  );
  await interstitialAd!.show();
}

Future<void> createInterstitialAd() async {
  final Completer<void> completer = Completer();

  InterstitialAd.load(
    adUnitId: kReleaseMode
        ? getInterstitialAdUnitId()!
        : Platform.isIOS
            ? userStore.admobInterstitialIdIos
            : userStore.admobInterstitialId,
    request: AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
      onAdLoaded: (InterstitialAd ad) {
        print('$ad loaded');
        interstitialAd = ad;
        if (!completer.isCompleted) completer.complete();

      },
      onAdFailedToLoad: (LoadAdError error) {
        print('InterstitialAd failed to load: $error.');
        interstitialAd = null;
        if (!completer.isCompleted) completer.complete();

      },
    ),
  );

  return completer.future;
}

disposeAdd() {
  interstitialAd?.dispose();
}

String? getInterstitialAdUnitId() {
  if (Platform.isIOS) {
    return userStore.admobInterstitialIdIos;
  } else if (Platform.isAndroid) {
    return userStore.admobInterstitialId;
  }
  return null;
}

String? getBannerAdUnitId() {
  if (Platform.isIOS) {
    return userStore.admobBannerIdIos;
  } else if (Platform.isAndroid) {
    return userStore.admobBannerId;
  }
  return null;
}

String? getNativeAdUnitId() {
  if (Platform.isIOS) {
    return userStore.nativeAdIdIos;
  } else if (Platform.isAndroid) {
    return userStore.nativeAdId;
  }
  return null;
}

Widget showBannerAds(BuildContext context) {
  return Container(
    height: 50,
    width: MediaQuery.of(context).size.width,
    child: AdWidget(
      ad: BannerAd(
        adUnitId: getBannerAdUnitId()!,
        size: AdSize.fullBanner,
        request: AdRequest(),
        listener: BannerAdListener(),
      )..load(),
    ),
  );
}

void loadInterstitialAds() {
  if (userStore.isSubscribe == 0) {
    createInterstitialAd();
  }
}

void showInterstitialAds() {
  if (userStore.isSubscribe == 0) {
    adShow();
  }
}

Map<int, NativeAd> ads = {};
Map<int, ValueNotifier<bool>> adLoaded = {};
Map<int, ValueNotifier<bool>> adLoading = {};


void loadAd(int index, bool shouldShowAds, bool? isBanner) {
  if (!shouldShowAds) return;

  adLoaded[index] ??= ValueNotifier(false);
  adLoading[index] ??= ValueNotifier(false);

  if (ads.containsKey(index) || adLoading[index]!.value) return;

  adLoading[index]!.value = true;

  final nativeAd = NativeAd(
    adUnitId: getNativeAdUnitId().validate(),
    factoryId: isBanner.validate() ? 'bannerTile' : 'listTile',
    request: const AdRequest(),
    listener: NativeAdListener(
      onAdLoaded: (ad) {
        adLoading[index]!.value = false;
        adLoaded[index]!.value = true;
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
        adLoading[index]!.value = false;
        adLoaded[index]!.value = false;
        debugPrint('Ad failed at index $index → $error');
      },
    ),
  );

  ads[index] = nativeAd;
  nativeAd.load();
}

Widget buildAdPlaceholder() {
  return Column(
    children: [
      Container(
        color: Colors.grey[100],
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: 40),
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text("Ad loading...", style: TextStyle(color: Colors.grey)),
            SizedBox(height: 10),
          ],
        ),
      ),
      20.height
    ],
  );
}