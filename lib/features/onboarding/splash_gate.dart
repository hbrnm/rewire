import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/home/spark_orb.dart';
import 'package:rewire/routes/app_router.dart';

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    try {
      final user = await ref.read(userProvider.future);
      if (!mounted) return;
      final target = user.displayName == null ? AppRouter.start : AppRouter.home;
      Navigator.of(context).pushReplacementNamed(target);
    } catch (_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.start);
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseOk = ref.watch(firebaseReadyProvider) && Firebase.apps.isNotEmpty;
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SparkOrb(size: 140),
              const SizedBox(height: 28),
              const Text(
                'Rewire',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                firebaseOk ? 'Se așază totul…' : 'Mod offline — totul rămâne la tine',
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
