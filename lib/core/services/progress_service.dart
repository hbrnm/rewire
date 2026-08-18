import 'package:uuid/uuid.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/star_model.dart';
import 'package:rewire/models/trigger_log_model.dart';

class ProgressService {
  ProgressService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  Future<void> maybeAwardStar({
    required String userId,
    required TriggerLogModel log,
  }) async {
    if (!log.outcome.earnsStar) return;
    await _db.addStar(
      StarModel(
        id: _uuid.v4(),
        userId: userId,
        createdAt: DateTime.now(),
        sourceLogId: log.id,
      ),
    );
  }

  Future<int> stars(String userId) => _db.starCount(userId);

  Future<List<StarModel>> constellation(String userId) => _db.listStars(userId);
}
