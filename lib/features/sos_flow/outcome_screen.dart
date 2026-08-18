import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/home/spark_orb.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/routes/app_router.dart';

class OutcomeScreen extends ConsumerStatefulWidget {
  const OutcomeScreen({super.key, this.logId});

  final String? logId;

  @override
  ConsumerState<OutcomeScreen> createState() => _OutcomeScreenState();
}

class _OutcomeScreenState extends ConsumerState<OutcomeScreen> {
  bool _saving = false;

  Future<void> _choose(UrgeOutcome outcome) async {
    setState(() => _saving = true);
    final logId = widget.logId;
    if (logId == null) {
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    final db = ref.read(databaseProvider);
    final log = await db.getTriggerLog(logId);
    if (log == null) {
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
      return;
    }

    final updated = log.copyWith(outcome: outcome, synced: false);
    await db.upsertTriggerLog(updated);

    final user = await ref.read(userProvider.future);
    await ref.read(progressServiceProvider).maybeAwardStar(userId: user.id, log: updated);

    final notifications = ref.read(notificationServiceProvider);
    if (user.notificationsEnabled) {
      await notifications.scheduleFollowUp(
        delay: const Duration(minutes: 90),
        incognito: user.incognitoMode,
      );
    }

    await ref.read(syncServiceProvider).syncIfPossible(user);
    ref.invalidate(logsProvider);
    ref.invalidate(starsProvider);

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(_headline(outcome)),
        content: Text(_body(outcome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mulțumesc, Spark'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(AppRouter.home, (r) => false);
  }

  String _headline(UrgeOutcome outcome) {
    switch (outcome) {
      case UrgeOutcome.resisted:
        return 'O stea nouă pe cer.';
      case UrgeOutcome.alternative:
        return 'Ai ales altceva. Asta e rewire.';
      case UrgeOutcome.acted:
        return 'Te-ai oprit să observi. Contează.';
      case UrgeOutcome.pending:
        return 'Spark rămâne aici.';
    }
  }

  String _body(UrgeOutcome outcome) {
    switch (outcome) {
      case UrgeOutcome.resisted:
        return 'Nu e o victorie împotriva ta. E o clipă în care ai rămas cu tine.';
      case UrgeOutcome.alternative:
        return 'Dopamina poate veni și din locuri care nu te rănesc. Ai demonstrat-o acum.';
      case UrgeOutcome.acted:
        return 'Fără recădere ca eșec. Fără rușine. Mâine e un alt val, și Spark tot e aici.';
      case UrgeOutcome.pending:
        return 'Poți închide ecranul. Check-in-ul de mai târziu e opțional.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              children: [
                const SparkOrb(size: 140, mood: SparkMood.celebrate),
                const SizedBox(height: 20),
                const Text(
                  'Cum a fost, de fapt?',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Alege ce e adevărat, nu ce „trebuie”. Nu există răspuns greșit.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const Spacer(),
                _OutcomeButton(
                  label: 'Am trecut peste',
                  subtitle: 'Valul a scăzut. Adaugă o stea.',
                  onTap: _saving ? null : () => _choose(UrgeOutcome.resisted),
                ),
                const SizedBox(height: 10),
                _OutcomeButton(
                  label: 'Am ales o alternativă',
                  subtitle: 'Am înlocuit impulsul cu altceva.',
                  onTap: _saving ? null : () => _choose(UrgeOutcome.alternative),
                ),
                const SizedBox(height: 10),
                _OutcomeButton(
                  label: 'Am cedat — și tot e ok',
                  subtitle: 'Fără rușine. Observarea rămâne.',
                  muted: true,
                  onTap: _saving ? null : () => _choose(UrgeOutcome.acted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutcomeButton extends StatelessWidget {
  const _OutcomeButton({
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final String subtitle;
  final VoidCallback? onTap;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: muted ? AppColors.muted : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
