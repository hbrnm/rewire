import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:rewire/core/constants/app_colors.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/features/common/night_background.dart';
import 'package:rewire/models/dopamine_item_model.dart';

class DopamineMenuScreen extends ConsumerStatefulWidget {
  const DopamineMenuScreen({super.key, this.selectable = false});

  final bool selectable;

  @override
  ConsumerState<DopamineMenuScreen> createState() => _DopamineMenuScreenState();
}

class _DopamineMenuScreenState extends ConsumerState<DopamineMenuScreen> {
  DopamineCategory _category = DopamineCategory.aperitiv;

  Future<void> _addCustom() async {
    final title = TextEditingController();
    final minutes = TextEditingController(text: '10');
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Alternativă personală'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(hintText: 'Ce îți face bine?'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: minutes,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'Minute'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Renunță')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Adaugă')),
        ],
      ),
    );
    if (ok != true || title.text.trim().isEmpty) return;
    final duration = int.tryParse(minutes.text) ?? 10;
    final user = await ref.read(userProvider.future);
    await ref.read(databaseProvider).upsertDopamineItem(
          DopamineItemModel(
            id: const Uuid().v4(),
            title: title.text.trim(),
            category: _category,
            durationMinutes: duration.clamp(1, 180),
            isCustom: true,
          ),
        );
    await ref.read(syncServiceProvider).syncIfPossible(user);
    ref.invalidate(dopamineItemsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(dopamineItemsProvider);

    return NightBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Meniu dopamină'),
          actions: [
            IconButton(
              onPressed: _addCustom,
              icon: const Icon(Icons.add),
              tooltip: 'Adaugă',
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<DopamineCategory>(
                segments: [
                  for (final c in DopamineCategory.values)
                    ButtonSegment(value: c, label: Text(c.label)),
                ],
                selected: {_category},
                onSelectionChanged: (s) => setState(() => _category = s.first),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _category.subtitle,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            ),
            Expanded(
              child: items.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('$e')),
                data: (all) {
                  final filtered = all.where((i) => i.category == _category).toList();
                  if (filtered.isEmpty) {
                    return const Center(
                      child: Text('Nimic aici încă.', style: TextStyle(color: AppColors.muted)),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return Card(
                        child: ListTile(
                          onTap: widget.selectable
                              ? () => Navigator.pop(context, item.title)
                              : null,
                          title: Text(item.title),
                          subtitle: Text(
                            [
                              '${item.durationMinutes} min',
                              if (item.description != null) item.description!,
                              if (item.isCustom) 'a ta',
                            ].join(' · '),
                          ),
                          trailing: widget.selectable
                              ? const Icon(Icons.chevron_right)
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
