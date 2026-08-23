// File generated from android/app/google-services.json (Android only).
// T002 — projeto andenken-ed808, package com.turial_dev.andenken.app

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for '
          '$defaultTargetPlatform. v1 is Android-only.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB9PcbPP42y_yR1pPlXje1ewc4FTgaX3So',
    appId: '1:361762132325:android:1c513c714a2d3469c6118c',
    messagingSenderId: '361762132325',
    projectId: 'andenken-ed808',
    storageBucket: 'andenken-ed808.firebasestorage.app',
  );
}
