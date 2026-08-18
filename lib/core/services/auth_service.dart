import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/user_model.dart';

class AuthService {
  AuthService(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  bool get firebaseReady => Firebase.apps.isNotEmpty;

  Future<UserModel> ensureUser() async {
    final existing = await _db.getUser();
    if (existing != null) return existing;

    var id = _uuid.v4();
    if (firebaseReady) {
      try {
        final credential = await FirebaseAuth.instance.signInAnonymously();
        id = credential.user?.uid ?? id;
      } catch (error) {
        debugPrint('Auth anonimă eșuată, folosim ID local: $error');
      }
    }

    final user = UserModel(id: id, createdAt: DateTime.now());
    await _db.saveUser(user);
    return user;
  }

  Future<UserModel> updateUser(UserModel user) async {
    await _db.saveUser(user);
    return user;
  }
}
