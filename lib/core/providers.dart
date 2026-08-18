import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/core/services/auth_service.dart';
import 'package:rewire/core/services/notification_service.dart';
import 'package:rewire/core/services/progress_service.dart';
import 'package:rewire/core/services/risk_pattern_analyzer.dart';
import 'package:rewire/core/services/sync_service.dart';
import 'package:rewire/models/dopamine_item_model.dart';
import 'package:rewire/models/star_model.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/models/user_model.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  throw StateError('databaseProvider trebuie suprascris în main()/teste.');
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw StateError('notificationServiceProvider trebuie suprascris în main()/teste.');
});

final firebaseReadyProvider = Provider<bool>((ref) => false);

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(databaseProvider)),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(ref.watch(databaseProvider)),
);

final progressServiceProvider = Provider<ProgressService>(
  (ref) => ProgressService(ref.watch(databaseProvider)),
);

final riskAnalyzerProvider = Provider<RiskPatternAnalyzer>(
  (ref) => const RiskPatternAnalyzer(),
);

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel>(UserNotifier.new);

class UserNotifier extends AsyncNotifier<UserModel> {
  @override
  Future<UserModel> build() async {
    final user = await ref.read(authServiceProvider).ensureUser();
    await ref.read(syncServiceProvider).syncIfPossible(user);
    return user;
  }

  Future<void> save(UserModel user) async {
    state = AsyncData(await ref.read(authServiceProvider).updateUser(user));
    await ref.read(syncServiceProvider).syncIfPossible(user);
  }
}

final logsProvider = FutureProvider<List<TriggerLogModel>>((ref) async {
  final user = await ref.watch(userProvider.future);
  return ref.watch(databaseProvider).listTriggerLogs(user.id);
});

final dopamineItemsProvider = FutureProvider<List<DopamineItemModel>>((ref) {
  return ref.watch(databaseProvider).listDopamineItems();
});

final starsProvider = FutureProvider<List<StarModel>>((ref) async {
  final user = await ref.watch(userProvider.future);
  return ref.watch(progressServiceProvider).constellation(user.id);
});
