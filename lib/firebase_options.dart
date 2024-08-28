// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs6uR8DIzhyftRSte8b3yuJn3tCzDv-00',
    appId: '1:107454696777:web:cb3f90ec3c073cc31cde98',
    messagingSenderId: '107454696777',
    projectId: 'flutterauth-46d66',
    authDomain: 'flutterauth-46d66.firebaseapp.com',
    storageBucket: 'flutterauth-46d66.appspot.com',
    measurementId: 'G-Z50NLC8RMN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpdeLY1xcWSOSJcVmUHOeKy_7Xv8kggyc',
    appId: '1:107454696777:android:7a8fdd21269d0b301cde98',
    messagingSenderId: '107454696777',
    projectId: 'flutterauth-46d66',
    storageBucket: 'flutterauth-46d66.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAx-yQ6mCL11KF8v3n0mwBpugCdbXqapBM',
    appId: '1:107454696777:ios:7e3da1a13055ccc41cde98',
    messagingSenderId: '107454696777',
    projectId: 'flutterauth-46d66',
    storageBucket: 'flutterauth-46d66.appspot.com',
    iosBundleId: 'com.example.test2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAx-yQ6mCL11KF8v3n0mwBpugCdbXqapBM',
    appId: '1:107454696777:ios:7e3da1a13055ccc41cde98',
    messagingSenderId: '107454696777',
    projectId: 'flutterauth-46d66',
    storageBucket: 'flutterauth-46d66.appspot.com',
    iosBundleId: 'com.example.test2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBs6uR8DIzhyftRSte8b3yuJn3tCzDv-00',
    appId: '1:107454696777:web:cb5de4364f7b20291cde98',
    messagingSenderId: '107454696777',
    projectId: 'flutterauth-46d66',
    authDomain: 'flutterauth-46d66.firebaseapp.com',
    storageBucket: 'flutterauth-46d66.appspot.com',
    measurementId: 'G-X01GXQE2QX',
  );

}