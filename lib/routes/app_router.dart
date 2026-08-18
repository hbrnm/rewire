import 'package:flutter/material.dart';
import 'package:rewire/features/dopamine_menu/dopamine_menu_screen.dart';
import 'package:rewire/features/home/home_shell.dart';
import 'package:rewire/features/onboarding/splash_gate.dart';
import 'package:rewire/features/onboarding/start_screen.dart';
import 'package:rewire/features/progress/progress_screen.dart';
import 'package:rewire/features/settings/settings_screen.dart';
import 'package:rewire/features/sos_flow/outcome_screen.dart';
import 'package:rewire/features/sos_flow/sos_flow_screen.dart';
import 'package:rewire/features/trigger_log/follow_up_screen.dart';
import 'package:rewire/features/trigger_log/trigger_log_screen.dart';

abstract final class AppRouter {
  static const splash = '/';
  static const start = '/start';
  static const home = '/home';
  static const sos = '/sos';
  static const outcome = '/outcome';
  static const triggerLog = '/trigger-log';
  static const followUp = '/follow-up';
  static const progress = '/progress';
  static const dopamine = '/dopamine';
  static const settings = '/settings';

  static Route<dynamic> onGenerateRoute(RouteSettings routeSettings) {
    final name = routeSettings.name ?? splash;
    switch (name) {
      case splash:
        return _fade(const SplashGate(), routeSettings);
      case start:
        return _fade(const StartScreen(), routeSettings);
      case home:
        return _fade(const HomeShell(), routeSettings);
      case sos:
        return MaterialPageRoute(
          builder: (_) => const SosFlowScreen(),
          settings: routeSettings,
        );
      case outcome:
        return MaterialPageRoute(
          builder: (_) => OutcomeScreen(logId: routeSettings.arguments as String?),
          settings: routeSettings,
        );
      case triggerLog:
        return MaterialPageRoute(
          builder: (_) => const TriggerLogScreen(),
          settings: routeSettings,
        );
      case followUp:
        return MaterialPageRoute(
          builder: (_) => const FollowUpScreen(),
          settings: routeSettings,
        );
      case progress:
        return MaterialPageRoute(
          builder: (_) => const ProgressScreen(),
          settings: routeSettings,
        );
      case dopamine:
        return MaterialPageRoute(
          builder: (_) => DopamineMenuScreen(selectable: routeSettings.arguments == true),
          settings: routeSettings,
        );
      case settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: routeSettings,
        );
      default:
        return _fade(const SplashGate(), routeSettings);
    }
  }

  static PageRoute _fade(Widget child, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}
