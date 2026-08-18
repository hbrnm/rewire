import 'package:rewire/models/dopamine_item_model.dart';
import 'package:rewire/models/star_model.dart';
import 'package:rewire/models/trigger_log_model.dart';
import 'package:rewire/models/user_model.dart';

abstract class AppDatabase {
  Future<void> init();

  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);

  Future<void> upsertTriggerLog(TriggerLogModel log);
  Future<List<TriggerLogModel>> listTriggerLogs(String userId);
  Future<TriggerLogModel?> getTriggerLog(String id);
  Future<List<TriggerLogModel>> unsyncedTriggerLogs(String userId);

  Future<void> upsertDopamineItem(DopamineItemModel item);
  Future<List<DopamineItemModel>> listDopamineItems();
  Future<List<DopamineItemModel>> unsyncedCustomItems();

  Future<void> addStar(StarModel star);
  Future<List<StarModel>> listStars(String userId);
  Future<int> starCount(String userId);

  Future<void> markTriggerSynced(String id);
  Future<void> markDopamineSynced(String id);
}
