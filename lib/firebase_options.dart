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
    apiKey: 'AIzaSyAb637ceDLCQqcp7ml7V5-0AHXHkLtTlT4',
    appId: '1:135244284170:web:aaf01acfe2918e14f8faf3',
    messagingSenderId: '135244284170',
    projectId: 'ichibanauto-flutter',
    authDomain: 'ichibanauto-flutter.firebaseapp.com',
    storageBucket: 'ichibanauto-flutter.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCgCEL6K0uThlL3BmJ2wdfVYvL1r03ge0g',
    appId: '1:135244284170:android:4ef75342785175fff8faf3',
    messagingSenderId: '135244284170',
    projectId: 'ichibanauto-flutter',
    storageBucket: 'ichibanauto-flutter.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB251IkLdsEv8j9OtswP1FlX4Ene-hIxa4',
    appId: '1:135244284170:ios:6ff812a685bcfd60f8faf3',
    messagingSenderId: '135244284170',
    projectId: 'ichibanauto-flutter',
    storageBucket: 'ichibanauto-flutter.appspot.com',
    iosBundleId: 'com.mdjoynulabedinshokal.ichibanauto',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB251IkLdsEv8j9OtswP1FlX4Ene-hIxa4',
    appId: '1:135244284170:ios:6ff812a685bcfd60f8faf3',
    messagingSenderId: '135244284170',
    projectId: 'ichibanauto-flutter',
    storageBucket: 'ichibanauto-flutter.appspot.com',
    iosBundleId: 'com.mdjoynulabedinshokal.ichibanauto',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAb637ceDLCQqcp7ml7V5-0AHXHkLtTlT4',
    appId: '1:135244284170:web:fb9b3c54561c94a5f8faf3',
    messagingSenderId: '135244284170',
    projectId: 'ichibanauto-flutter',
    authDomain: 'ichibanauto-flutter.firebaseapp.com',
    storageBucket: 'ichibanauto-flutter.appspot.com',
  );
}
