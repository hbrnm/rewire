import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/home/spark_orb.dart';
import 'package:rewire/routes/app_router.dart';

class FollowUpScreen extends ConsumerWidget {
  const FollowUpScreen({super.key});

  Future<void> _closeLatest(WidgetRef ref, BuildContext context) async {
    final logs = await ref.read(logsProvider.future);
    if (logs.isNotEmpty) {
      final latest = logs.first.copyWith(followUpDone: true, synced: false);
      await ref.read(databaseProvider).upsertTriggerLog(latest);
      ref.invalidate(logsProvider);
    }
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Check-in')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SparkOrb(size: 120, mood: SparkMood.support),
              const SizedBox(height: 24),
              const Text(
                'Cum e acum, la distanță de val?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nu e un test. E o privire înapoi, dacă vrei să o arunci.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.muted, height: 1.4),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => _closeLatest(ref, context),
                  child: const Text('Mai liniștit acum'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed(AppRouter.sos),
                  child: const Text('Valul e încă aici — Rewire Now'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => _closeLatest(ref, context),
                child: const Text('Închide, fără să răspund'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
