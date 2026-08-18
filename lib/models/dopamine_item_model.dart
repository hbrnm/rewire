enum DopamineCategory {
  aperitiv,
  felPrincipal,
  desert,
}

extension DopamineCategoryX on DopamineCategory {
  String get storage {
    switch (this) {
      case DopamineCategory.aperitiv:
        return 'aperitiv';
      case DopamineCategory.felPrincipal:
        return 'fel_principal';
      case DopamineCategory.desert:
        return 'desert';
    }
  }

  String get label {
    switch (this) {
      case DopamineCategory.aperitiv:
        return 'Aperitiv';
      case DopamineCategory.felPrincipal:
        return 'Fel principal';
      case DopamineCategory.desert:
        return 'Desert';
    }
  }

  String get subtitle {
    switch (this) {
      case DopamineCategory.aperitiv:
        return '1–5 minute';
      case DopamineCategory.felPrincipal:
        return '10–20 minute';
      case DopamineCategory.desert:
        return '30+ minute';
    }
  }

  static DopamineCategory fromStorage(String? value) {
    switch (value) {
      case 'fel_principal':
        return DopamineCategory.felPrincipal;
      case 'desert':
        return DopamineCategory.desert;
      default:
        return DopamineCategory.aperitiv;
    }
  }
}

class DopamineItemModel {
  const DopamineItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    this.description,
    this.isCustom = false,
    this.synced = false,
  });

  final String id;
  final String title;
  final String? description;
  final DopamineCategory category;
  final int durationMinutes;
  final bool isCustom;
  final bool synced;

  Map<String, Object?> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.storage,
        'duration_minutes': durationMinutes,
        'is_custom': isCustom ? 1 : 0,
        'synced': synced ? 1 : 0,
      };

  factory DopamineItemModel.fromMap(Map<String, Object?> map) {
    return DopamineItemModel(
      id: map['id']! as String,
      title: map['title']! as String,
      description: map['description'] as String?,
      category: DopamineCategoryX.fromStorage(map['category'] as String?),
      durationMinutes: map['duration_minutes'] as int? ?? 5,
      isCustom: (map['is_custom'] as int? ?? 0) == 1,
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toFirestore() => {
        'title': title,
        'description': description,
        'category': category.storage,
        'durationMinutes': durationMinutes,
      };
}
