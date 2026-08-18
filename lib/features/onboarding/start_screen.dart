import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/home/spark_orb.dart';
import 'package:rewire/routes/app_router.dart';

class StartScreen extends ConsumerStatefulWidget {
  const StartScreen({super.key});

  @override
  ConsumerState<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends ConsumerState<StartScreen> {
  bool _busy = false;

  Future<void> _enter() async {
    setState(() => _busy = true);
    final current = await ref.read(userProvider.future);
    await ref.read(userProvider.notifier).save(
          current.copyWith(displayName: current.displayName ?? 'Eu'),
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.home);
  }

  @override
  Widget build(BuildContext context) {
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                const SparkOrb(size: 160),
                const SizedBox(height: 32),
                const Text(
                  'Fără judecată.\nFără recădere ca eșec.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Rewire e un spațiu privat, offline-first. Spark stă lângă tine când apare impulsul — nu ca să te corecteze, ci ca să-ți țină locul până trece valul.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.muted,
                    height: 1.45,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _enter,
                    child: Text(_busy ? 'Intrăm…' : 'Intră anonim'),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Creăm un cont anonim. Nimic de memorat, nimic de dovedit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
