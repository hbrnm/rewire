import 'package:flutter/material.dart';
import 'package:rewire/core/constants/app_theme.dart';
import 'package:rewire/core/navigation/app_navigator.dart';
import 'package:rewire/routes/app_router.dart';

class RewireApp extends StatelessWidget {
  const RewireApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rewire',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(),
      navigatorKey: AppNavigator.key,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: AppRouter.splash,
    );
  }
}
