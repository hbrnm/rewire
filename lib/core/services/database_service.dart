import 'package:flutter/foundation.dart';
import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/core/services/db_factory.dart';
import 'package:rewire/core/services/memory_database.dart';
import 'package:rewire/core/services/seed_data.dart';
import 'package:rewire/core/services/sqlite_database.dart';

Future<AppDatabase> openAppDatabase() async {
  if (kIsWeb) {
    final memory = MemoryAppDatabase();
    await memory.init();
    await SeedData.ensure(memory);
    return memory;
  }

  try {
    configureDatabaseFactory();
    final sqlite = SqliteAppDatabase();
    await sqlite.init();
    await SeedData.ensure(sqlite);
    return sqlite;
  } catch (error, stack) {
    debugPrint('SQLite indisponibil, continuăm in-memory: $error\n$stack');
    final memory = MemoryAppDatabase();
    await memory.init();
    await SeedData.ensure(memory);
    return memory;
  }
}
