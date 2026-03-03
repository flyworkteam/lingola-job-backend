// Bu dosya `flutterfire configure` çalıştırıldığında otomatik güncellenir.
// Firebase Console'dan projeyi ekleyip terminalde: flutterfire configure
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return android;
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBxWRYeCkkQLOlHlNhATayHRluKZuyVRBk',
    appId: '1:542145601165:android:3060efea19f6f4e0ae4cc4',
    messagingSenderId: '542145601165',
    projectId: 'lingola-backend',
    storageBucket: 'lingola-backend.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC4YfOhl20LHIClxmAImVvwE2XnZe3SRFM',
    appId: '1:542145601165:ios:bc59c1e30578fe76ae4cc4',
    messagingSenderId: '542145601165',
    projectId: 'lingola-backend',
    storageBucket: 'lingola-backend.firebasestorage.app',
    iosBundleId: 'com.flywork.lingolajobapp.RunnerTests',
  );
}
