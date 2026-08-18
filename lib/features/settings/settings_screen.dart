import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final logs = ref.watch(logsProvider);
    final analyzer = ref.watch(riskAnalyzerProvider);
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Setări')),
        body: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (user) {
            final suggestedHour = logs.maybeWhen(
              data: (items) => analyzer.peakHour(items.map((e) => e.createdAt).toList()),
              orElse: () => null,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                const Text(
                  'Totul e opțional. Nimic nu rulează „în tăcere” fără acordul tău.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: user.notificationsEnabled,
                  title: const Text('Notificări'),
                  subtitle: const Text('Follow-up după Rewire Now, dacă le lași pornite.'),
                  onChanged: (value) async {
                    final next = user.copyWith(notificationsEnabled: value);
                    await ref.read(userProvider.notifier).save(next);
                    if (!value) {
                      await ref.read(notificationServiceProvider).cancelFollowUp();
                      await ref.read(notificationServiceProvider).cancelDailyCheckIn();
                    } else {
                      await ref.read(notificationServiceProvider).requestPermission();
                    }
                  },
                ),
                SwitchListTile(
                  value: user.incognitoMode,
                  title: const Text('Mod incognito'),
                  subtitle: const Text(
                    'Oprește sincronizarea cloud și face textele din notificări generice.',
                  ),
                  onChanged: (value) async {
                    await ref.read(userProvider.notifier).save(
                          user.copyWith(incognitoMode: value),
                        );
                  },
                ),
                const Divider(height: 32),
                const Text(
                  'Check-in blând',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                if (suggestedHour == null)
                  const Text(
                    'Când ai măcar câteva note în jurnal, Spark poate sugera o oră — tu decizi dacă o activezi.',
                    style: TextStyle(color: AppColors.muted),
                  )
                else ...[
                  Text(
                    'Din istoricul local, impulsul apare cel mai des pe la ${analyzer.formatHour(suggestedHour)}.',
                    style: const TextStyle(color: AppColors.muted, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  if (user.checkInHour == suggestedHour)
                    OutlinedButton(
                      onPressed: () async {
                        await ref.read(notificationServiceProvider).cancelDailyCheckIn();
                        await ref.read(userProvider.notifier).save(
                              user.copyWith(clearCheckInHour: true),
                            );
                      },
                      child: const Text('Oprește check-in-ul zilnic'),
                    )
                  else
                    FilledButton(
                      onPressed: () async {
                        final allowed =
                            await ref.read(notificationServiceProvider).requestPermission();
                        if (!allowed && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Fără permisiune, check-in-ul nu poate fi programat. Poți reîncerca din setările sistemului.',
                              ),
                            ),
                          );
                        }
                        await ref.read(notificationServiceProvider).scheduleDailyCheckIn(
                              suggestedHour,
                              incognito: user.incognitoMode,
                            );
                        await ref.read(userProvider.notifier).save(
                              user.copyWith(
                                checkInHour: suggestedHour,
                                notificationsEnabled: true,
                              ),
                            );
                      },
                      child: Text(
                        'Vreau un check-in blând atunci (${analyzer.formatHour(suggestedHour)})',
                      ),
                    ),
                ],
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    title: const Text('Cont'),
                    subtitle: Text(
                      [
                        'ID local: ${user.id.substring(0, 8)}…',
                        if (user.lastSyncedAt != null)
                          'Ultima sync: ${user.lastSyncedAt}',
                        if (user.incognitoMode) 'Incognito — fără cloud',
                      ].join('\n'),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
