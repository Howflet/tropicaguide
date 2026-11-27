import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return web;
      case TargetPlatform.linux:
        return web;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC3dsWIM0k2C7ChnDuN-_R5twRHXmYqMnQ',
    appId: '1:576400976882:web:b44adb1631d11c7543196b',
    messagingSenderId: '576400976882',
    projectId: 'tropicaguide-mad26',
    authDomain: 'tropicaguide-mad26.firebaseapp.com',
    storageBucket: 'tropicaguide-mad26.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAv7QnMYPf_1SSWFAouN-A3H6xxAUcqI8w',
    appId: '1:576400976882:android:51c0c08bf05fa40a43196b',
    messagingSenderId: '576400976882',
    projectId: 'tropicaguide-mad26',
    storageBucket: 'tropicaguide-mad26.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDLq7hgokKilcTe_Z1GoDKGVh9_2fdV8xA',
    appId: '1:576400976882:ios:dd9bbf87c7806f6243196b',
    messagingSenderId: '576400976882',
    projectId: 'tropicaguide-mad26',
    storageBucket: 'tropicaguide-mad26.firebasestorage.app',
    iosBundleId: 'edu.gsu.cs.tropicaguide.tropicaguide',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDLq7hgokKilcTe_Z1GoDKGVh9_2fdV8xA',
    appId: '1:576400976882:ios:dd9bbf87c7806f6243196b',
    messagingSenderId: '576400976882',
    projectId: 'tropicaguide-mad26',
    storageBucket: 'tropicaguide-mad26.firebasestorage.app',
    iosBundleId: 'edu.gsu.cs.tropicaguide.tropicaguide',
  );
}
