import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/app.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/core/services/database_service.dart';
import 'package:rewire/core/services/notification_service.dart';
import 'package:rewire/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (error) {
    debugPrint('Firebase indisponibil — pornim offline-first: $error');
  }

  final database = await openAppDatabase();
  final notifications = NotificationService();
  await notifications.init();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        notificationServiceProvider.overrideWithValue(notifications),
        firebaseReadyProvider.overrideWithValue(firebaseReady),
      ],
      child: const RewireApp(),
    ),
  );
}
