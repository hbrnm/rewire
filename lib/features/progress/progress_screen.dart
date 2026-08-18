import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/progress/constellation.dart';
import 'package:rewire/models/trigger_log_model.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stars = ref.watch(starsProvider);
    final logs = ref.watch(logsProvider);
    final nested = ModalRoute.of(context)?.canPop ?? false;

    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(nested ? 'Constelația' : 'Stelele tale')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Fiecare stea e o clipă în care ai rămas cu tine. Nu un scor. Nu o serie de rupt.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            stars.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('$e'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Cerul e încă gol. Prima stea apare când termini un Rewire Now cu „am trecut” sau „am ales altceva”.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return Column(
                  children: [
                    Text(
                      '${items.length}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        color: AppColors.spark,
                      ),
                    ),
                    Text(
                      items.length == 1 ? 'stea' : 'stele',
                      style: const TextStyle(color: AppColors.muted),
                    ),
                    const SizedBox(height: 8),
                    Constellation(stars: items),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            logs.maybeWhen(
              data: (items) {
                final resisted =
                    items.where((l) => l.outcome == UrgeOutcome.resisted).length;
                final alt =
                    items.where((l) => l.outcome == UrgeOutcome.alternative).length;
                final acted =
                    items.where((l) => l.outcome == UrgeOutcome.acted).length;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jurnal, pe scurt',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text('Valuri observate: ${items.length}',
                            style: const TextStyle(color: AppColors.muted)),
                        Text('Trecute: $resisted · Alternative: $alt · Cedate: $acted',
                            style: const TextStyle(color: AppColors.muted)),
                      ],
                    ),
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
