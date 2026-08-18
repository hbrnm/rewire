import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/models/trigger_log_model.dart';

class TriggerLogScreen extends ConsumerStatefulWidget {
  const TriggerLogScreen({super.key});

  @override
  ConsumerState<TriggerLogScreen> createState() => _TriggerLogScreenState();
}

class _TriggerLogScreenState extends ConsumerState<TriggerLogScreen> {
  final _label = TextEditingController();
  final _notes = TextEditingController();
  double _intensity = 5;
  bool _saving = false;

  @override
  void dispose() {
    _label.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final user = await ref.read(userProvider.future);
    await ref.read(databaseProvider).upsertTriggerLog(
          TriggerLogModel(
            id: const Uuid().v4(),
            userId: user.id,
            createdAt: DateTime.now(),
            triggerLabel: _label.text.trim().isEmpty ? null : _label.text.trim(),
            intensity: _intensity.round(),
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        );
    await ref.read(syncServiceProvider).syncIfPossible(user);
    ref.invalidate(logsProvider);
    if (!mounted) return;
    _label.clear();
    _notes.clear();
    setState(() {
      _intensity = 5;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notat. Fără analize, doar evidență.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(logsProvider);
    final nested = ModalRoute.of(context)?.canPop ?? false;

    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: nested
            ? AppBar(title: const Text('Jurnal rapid'))
            : AppBar(title: const Text('Jurnal')),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            const Text(
              'Un rând e de ajuns. Nu trebuie să fie frumos sau complet.',
              style: TextStyle(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _label,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Ce s-a trezit?'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notes,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'Context, dacă vrei'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Intensitate', style: TextStyle(color: AppColors.muted)),
                const Spacer(),
                Text('${_intensity.round()}/10',
                    style: const TextStyle(color: AppColors.spark)),
              ],
            ),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: const Text('Salvează local'),
            ),
            const SizedBox(height: 28),
            const Text(
              'Istoric',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            logs.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Text('$e'),
              data: (items) {
                if (items.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'Încă gol — și asta e o veste bună sau doar un început.',
                      style: TextStyle(color: AppColors.muted),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final log in items) _LogTile(log: log),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});

  final TriggerLogModel log;

  @override
  Widget build(BuildContext context) {
    final time =
        '${log.createdAt.day.toString().padLeft(2, '0')}.${log.createdAt.month.toString().padLeft(2, '0')}  ${log.createdAt.hour.toString().padLeft(2, '0')}:${log.createdAt.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(log.triggerLabel?.isNotEmpty == true ? log.triggerLabel! : 'Fără etichetă'),
        subtitle: Text(
          [
            time,
            if (log.intensity != null) 'intensitate ${log.intensity}',
            log.outcome.label,
          ].join(' · '),
        ),
      ),
    );
  }
}
