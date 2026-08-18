import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/user_model.dart';

class SyncService {
  SyncService(this._db);

  final AppDatabase _db;

  bool get _ready => Firebase.apps.isNotEmpty;

  Future<bool> get isOnline async {
    final results = await Connectivity().checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> syncIfPossible(UserModel user) async {
    if (!_ready || user.incognitoMode) return;
    if (!await isOnline) return;

    try {
      final firestore = FirebaseFirestore.instance;
      final userRef = firestore.collection('users').doc(user.id);
      await userRef.set(user.toFirestore(), SetOptions(merge: true));

      final logs = await _db.unsyncedTriggerLogs(user.id);
      for (final log in logs) {
        await userRef.collection('triggerLogs').doc(log.id).set(log.toFirestore());
        await _db.markTriggerSynced(log.id);
      }

      final items = await _db.unsyncedCustomItems();
      for (final item in items) {
        await userRef
            .collection('customDopamineItems')
            .doc(item.id)
            .set(item.toFirestore());
        await _db.markDopamineSynced(item.id);
      }

      await _db.saveUser(user.copyWith(lastSyncedAt: DateTime.now()));
    } catch (error) {
      debugPrint('Sincronizare amânată: $error');
    }
  }
}
