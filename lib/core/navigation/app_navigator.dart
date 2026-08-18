import 'package:flutter/material.dart';

/// Cheie globală — folosită de notificări pentru deep-link în app.
abstract final class AppNavigator {
  static final key = GlobalKey<NavigatorState>();
}
