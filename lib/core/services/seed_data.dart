import 'package:rewire/core/services/app_database.dart';
import 'package:rewire/models/dopamine_item_model.dart';

abstract final class SeedData {
  static const presets = <DopamineItemModel>[
    DopamineItemModel(
      id: 'preset-water',
      title: 'Un pahar de apă, lent',
      description: 'Bea-l ca și cum ai avea tot timpul din lume.',
      category: DopamineCategory.aperitiv,
      durationMinutes: 2,
    ),
    DopamineItemModel(
      id: 'preset-breath',
      title: '10 respirații vizibile',
      description: 'Inspiră pe 4, expiră pe 6. Atât.',
      category: DopamineCategory.aperitiv,
      durationMinutes: 2,
    ),
    DopamineItemModel(
      id: 'preset-cold',
      title: 'Apă rece pe față',
      description: 'Un reset scurt pentru sistemul nervos.',
      category: DopamineCategory.aperitiv,
      durationMinutes: 1,
    ),
    DopamineItemModel(
      id: 'preset-step',
      title: '3 minute afară sau la fereastră',
      description: 'Schimbă camera. Schimbă aerul.',
      category: DopamineCategory.aperitiv,
      durationMinutes: 3,
    ),
    DopamineItemModel(
      id: 'preset-stretch',
      title: 'Întinde-te pe spate',
      description: 'Umeri, gât, maxilar. Eliberează încordarea.',
      category: DopamineCategory.aperitiv,
      durationMinutes: 4,
    ),
    DopamineItemModel(
      id: 'preset-walk',
      title: 'O plimbare fără telefon',
      description: 'Nici măcar muzică, dacă poți. Doar pași.',
      category: DopamineCategory.felPrincipal,
      durationMinutes: 15,
    ),
    DopamineItemModel(
      id: 'preset-shower',
      title: 'Un duș cu intenție',
      description: 'Lasă apa să facă treaba. Tu doar ești acolo.',
      category: DopamineCategory.felPrincipal,
      durationMinutes: 12,
    ),
    DopamineItemModel(
      id: 'preset-tea',
      title: 'Ceai sau cafea, făcută de la zero',
      description: 'Ritualul contează mai mult decât băutura.',
      category: DopamineCategory.felPrincipal,
      durationMinutes: 10,
    ),
    DopamineItemModel(
      id: 'preset-tidy',
      title: 'Ordonează un colț mic',
      description: 'Nu toată camera. Un sertar, un blat, un raft.',
      category: DopamineCategory.felPrincipal,
      durationMinutes: 15,
    ),
    DopamineItemModel(
      id: 'preset-message',
      title: 'Un mesaj sincer cuiva',
      description: 'Nu trebuie să explici de ce. Doar „mă gândesc la tine”.',
      category: DopamineCategory.felPrincipal,
      durationMinutes: 10,
    ),
    DopamineItemModel(
      id: 'preset-cook',
      title: 'Gătește ceva simplu',
      description: 'Ouă, paste, o supă. Mâinile ocupate, mintea mai lină.',
      category: DopamineCategory.desert,
      durationMinutes: 35,
    ),
    DopamineItemModel(
      id: 'preset-move',
      title: 'Mișcare care îți place',
      description: 'Sală, dans în cameră, yoga pe YouTube — tu alegi.',
      category: DopamineCategory.desert,
      durationMinutes: 40,
    ),
    DopamineItemModel(
      id: 'preset-hobby',
      title: 'Hobby-ul pe care îl tot amâni',
      description: 'Desen, chitară, joc, puzzle. Fără performanță.',
      category: DopamineCategory.desert,
      durationMinutes: 45,
    ),
    DopamineItemModel(
      id: 'preset-film',
      title: 'Un film sau un episod, cu prezență',
      description: 'Telefonul în altă cameră, dacă reușești.',
      category: DopamineCategory.desert,
      durationMinutes: 50,
    ),
  ];

  static Future<void> ensure(AppDatabase db) async {
    final existing = await db.listDopamineItems();
    final ids = existing.map((e) => e.id).toSet();
    for (final item in presets) {
      if (!ids.contains(item.id)) {
        await db.upsertDopamineItem(item);
      }
    }
  }
}
