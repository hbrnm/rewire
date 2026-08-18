import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/dopamine_item_model.dart';
import 'package:rewire/models/star_model.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/models/user_model.dart';

/// Implementare in-memory — web, teste, sau fallback dacă SQLite nu pornește.
class MemoryAppDatabase implements AppDatabase {
  UserModel? _user;
  final Map<String, TriggerLogModel> _logs = {};
  final Map<String, DopamineItemModel> _items = {};
  final Map<String, StarModel> _stars = {};

  @override
  Future<void> init() async {}

  @override
  Future<UserModel?> getUser() async => _user;

  @override
  Future<void> saveUser(UserModel user) async => _user = user;

  @override
  Future<void> upsertTriggerLog(TriggerLogModel log) async => _logs[log.id] = log;

  @override
  Future<List<TriggerLogModel>> listTriggerLogs(String userId) async {
    final list = _logs.values.where((l) => l.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  Future<TriggerLogModel?> getTriggerLog(String id) async => _logs[id];

  @override
  Future<List<TriggerLogModel>> unsyncedTriggerLogs(String userId) async =>
      _logs.values.where((l) => l.userId == userId && !l.synced).toList();

  @override
  Future<void> upsertDopamineItem(DopamineItemModel item) async =>
      _items[item.id] = item;

  @override
  Future<List<DopamineItemModel>> listDopamineItems() async =>
      _items.values.toList();

  @override
  Future<List<DopamineItemModel>> unsyncedCustomItems() async =>
      _items.values.where((i) => i.isCustom && !i.synced).toList();

  @override
  Future<void> addStar(StarModel star) async => _stars[star.id] = star;

  @override
  Future<List<StarModel>> listStars(String userId) async {
    final list = _stars.values.where((s) => s.userId == userId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  @override
  Future<int> starCount(String userId) async =>
      _stars.values.where((s) => s.userId == userId).length;

  @override
  Future<void> markTriggerSynced(String id) async {
    final log = _logs[id];
    if (log != null) _logs[id] = log.copyWith(synced: true);
  }

  @override
  Future<void> markDopamineSynced(String id) async {
    final item = _items[id];
    if (item != null) {
      _items[id] = DopamineItemModel(
        id: item.id,
        title: item.title,
        description: item.description,
        category: item.category,
        durationMinutes: item.durationMinutes,
        isCustom: item.isCustom,
        synced: true,
      );
    }
  }
}
