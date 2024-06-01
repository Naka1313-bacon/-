import 'dart:io';

class AdHelper {
  static String get bannerAdUnitId1 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111';
    } else {
      // ignore: unnecessary_new
      throw new UnsupportedError('Unsupported platform');
    }
  }

// test-id ca-app-pub-3940256099942544/6300978111
  static String get bannerAdUnitId2 {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/9214589741';
    } else {
      // ignore: unnecessary_new
      throw new UnsupportedError('Unsupported platform');
    }
  }
}
// test-id ca-app-pub-3940256099942544/9214589741