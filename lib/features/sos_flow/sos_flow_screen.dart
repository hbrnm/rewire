import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/features/home/spark_orb.dart';
import 'package:rewire/models/dopamine_item_model.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/routes/app_router.dart';

enum _Phase { name, breathe, choose }

class SosFlowScreen extends ConsumerStatefulWidget {
  const SosFlowScreen({super.key});

  @override
  ConsumerState<SosFlowScreen> createState() => _SosFlowScreenState();
}

class _SosFlowScreenState extends ConsumerState<SosFlowScreen> {
  static const _uuid = Uuid();
  _Phase _phase = _Phase.name;
  late int _remaining;
  Timer? _timer;
  bool _canSkip = false;

  final _label = TextEditingController();
  double _intensity = 5;
  String? _chosenAlternative;
  late final String _logId;

  static const _durations = {
    _Phase.name: 30,
    _Phase.breathe: 60,
    _Phase.choose: 60,
  };

  @override
  void initState() {
    super.initState();
    _logId = _uuid.v4();
    _startPhase(_Phase.name);
  }

  void _startPhase(_Phase phase) {
    _timer?.cancel();
    setState(() {
      _phase = phase;
      _remaining = _durations[phase]!;
      _canSkip = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_remaining <= 1) {
        t.cancel();
        _advance();
        return;
      }
      setState(() {
        _remaining--;
        if (_remaining <= _durations[phase]! - 5) _canSkip = true;
      });
    });
  }

  Future<void> _advance() async {
    if (_phase == _Phase.name) {
      _startPhase(_Phase.breathe);
    } else if (_phase == _Phase.breathe) {
      _startPhase(_Phase.choose);
    } else {
      await _finish();
    }
  }

  Future<void> _finish() async {
    _timer?.cancel();
    final user = await ref.read(userProvider.future);
    final log = TriggerLogModel(
      id: _logId,
      userId: user.id,
      createdAt: DateTime.now(),
      triggerLabel: _label.text.trim().isEmpty ? null : _label.text.trim(),
      intensity: _intensity.round(),
      chosenAlternative: _chosenAlternative,
    );
    await ref.read(databaseProvider).upsertTriggerLog(log);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRouter.outcome, arguments: log.id);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _label.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_title),
          actions: [
            TextButton(
              onPressed: _canSkip ? _advance : null,
              child: Text(_phase == _Phase.choose ? 'Gata' : 'Sari'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              children: [
                _TimerRing(seconds: _remaining, total: _durations[_phase]!),
                const SizedBox(height: 20),
                Expanded(child: _body()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    switch (_phase) {
      case _Phase.name:
        return 'Numește impulsul';
      case _Phase.breathe:
        return 'Stai cu valul';
      case _Phase.choose:
        return 'Alege altceva';
    }
  }

  Widget _body() {
    switch (_phase) {
      case _Phase.name:
        return Column(
          children: [
            const Text(
              'Nu trebuie să-l urmezi. Ajunge să-l vezi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _label,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Ce îl trezește? (opțional)',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Intensitate', style: TextStyle(color: AppColors.muted)),
                const Spacer(),
                Text(
                  '${_intensity.round()}/10',
                  style: const TextStyle(color: AppColors.spark, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            Slider(
              min: 1,
              max: 10,
              divisions: 9,
              value: _intensity,
              onChanged: (v) => setState(() => _intensity = v),
            ),
          ],
        );
      case _Phase.breathe:
        return const Column(
          children: [
            SparkOrb(size: 200, mood: SparkMood.support, breathing: true),
            SizedBox(height: 24),
            Text(
              'Inspiră când Spark crește.\nExpiră când se micșorează.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.text, fontSize: 18, height: 1.4),
            ),
            SizedBox(height: 12),
            Text(
              'Valul trece și fără tine. Tu doar stai pe mal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted),
            ),
          ],
        );
      case _Phase.choose:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Dacă vrei, alege o alternativă scurtă. Dacă nu, e suficient că ai rămas aici.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ref.watch(dopamineItemsProvider).when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('$e'),
                    data: (items) {
                      final picks = items
                          .where((i) => i.durationMinutes <= 20)
                          .take(8)
                          .toList();
                      return ListView.separated(
                        itemCount: picks.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = picks[index];
                          final selected = _chosenAlternative == item.title;
                          return ListTile(
                            onTap: () => setState(() => _chosenAlternative = item.title),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: selected ? AppColors.spark : AppColors.outline,
                              ),
                            ),
                            tileColor: AppColors.surface,
                            title: Text(item.title),
                            subtitle: Text('${item.durationMinutes} min · ${item.category.label}'),
                            trailing: selected ? const Icon(Icons.check, color: AppColors.spark) : null,
                          );
                        },
                      );
                    },
                  ),
            ),
            TextButton(
              onPressed: () async {
                final result = await Navigator.of(context).pushNamed(
                  AppRouter.dopamine,
                  arguments: true,
                );
                if (result is String) {
                  setState(() => _chosenAlternative = result);
                }
              },
              child: const Text('Vezi tot meniul'),
            ),
          ],
        );
    }
  }
}

class _TimerRing extends StatelessWidget {
  const _TimerRing({required this.seconds, required this.total});

  final int seconds;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = seconds / total;
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            color: AppColors.spark,
            backgroundColor: AppColors.outline,
          ),
          Text(
            '${seconds}s',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
