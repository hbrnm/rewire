import 'package:flutter_test/flutter_test.dart';
import 'package:rewire/core/services/memory_database.dart';
import 'package:rewire/core/services/progress_service.dart';
import 'package:rewire/core/services/seed_data.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/models/user_model.dart';

void main() {
  test('seed data populates dopamine menu presets', () async {
    final db = MemoryAppDatabase();
    await db.init();
    await SeedData.ensure(db);
    final items = await db.listDopamineItems();
    expect(items.length, SeedData.presets.length);
    expect(items.any((i) => i.title.toLowerCase().contains('apă')), isTrue);
  });

  test('progress awards a star only for resisted or alternative outcomes', () async {
    final db = MemoryAppDatabase();
    await db.init();
    final progress = ProgressService(db);
    final user = UserModel(id: 'u1', createdAt: DateTime(2026, 1, 1));

    final resisted = TriggerLogModel(
      id: 'l1',
      userId: user.id,
      createdAt: DateTime.now(),
      outcome: UrgeOutcome.resisted,
    );
    final acted = TriggerLogModel(
      id: 'l2',
      userId: user.id,
      createdAt: DateTime.now(),
      outcome: UrgeOutcome.acted,
    );

    await progress.maybeAwardStar(userId: user.id, log: resisted);
    await progress.maybeAwardStar(userId: user.id, log: acted);

    expect(await progress.stars(user.id), 1);
  });
}
