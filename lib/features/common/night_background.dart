import 'package:flutter/material.dart';
import 'package:rewire/core/constants/app_colors.dart';

class NightBackground extends StatelessWidget {
  const NightBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.nightAlt, AppColors.night],
        ),
      ),
      child: child,
    );
  }
}
