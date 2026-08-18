import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rewire/app.dart';
import 'package:rewire/core/providers.dart';
import 'package:rewire/core/services/memory_database.dart';
import 'package:rewire/core/services/notification_service.dart';
import 'package:rewire/core/services/seed_data.dart';
import 'package:rewire/features/onboarding/start_screen.dart';

void main() {
  testWidgets('onboarding shows Rewire and anonymous entry', (tester) async {
    final db = MemoryAppDatabase();
    await db.init();
    await SeedData.ensure(db);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          notificationServiceProvider.overrideWithValue(NotificationService()),
          firebaseReadyProvider.overrideWithValue(false),
        ],
        child: const RewireApp(),
      ),
    );

    // Spark are animație infinită, deci nu folosim pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StartScreen), findsOneWidget);
    expect(find.text('Intră anonim'), findsOneWidget);
    expect(find.textContaining('Fără judecată'), findsOneWidget);

    await tester.tap(find.text('Intră anonim'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Rewire Now'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
