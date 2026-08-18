enum UrgeOutcome {
  pending,
  resisted,
  alternative,
  acted,
}

extension UrgeOutcomeX on UrgeOutcome {
  String get storage => name;

  String get label {
    switch (this) {
      case UrgeOutcome.pending:
        return 'În curs';
      case UrgeOutcome.resisted:
        return 'Am trecut peste';
      case UrgeOutcome.alternative:
        return 'Am ales o alternativă';
      case UrgeOutcome.acted:
        return 'Am cedat — și tot e ok';
    }
  }

  bool get earnsStar =>
      this == UrgeOutcome.resisted || this == UrgeOutcome.alternative;

  static UrgeOutcome fromStorage(String? value) {
    return UrgeOutcome.values.firstWhere(
      (o) => o.name == value,
      orElse: () => UrgeOutcome.pending,
    );
  }
}

class TriggerLogModel {
  const TriggerLogModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.triggerLabel,
    this.intensity,
    this.notes,
    this.outcome = UrgeOutcome.pending,
    this.followUpDone = false,
    this.chosenAlternative,
    this.synced = false,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String? triggerLabel;
  final int? intensity;
  final String? notes;
  final UrgeOutcome outcome;
  final bool followUpDone;
  final String? chosenAlternative;
  final bool synced;

  TriggerLogModel copyWith({
    String? triggerLabel,
    int? intensity,
    String? notes,
    UrgeOutcome? outcome,
    bool? followUpDone,
    String? chosenAlternative,
    bool? synced,
  }) {
    return TriggerLogModel(
      id: id,
      userId: userId,
      createdAt: createdAt,
      triggerLabel: triggerLabel ?? this.triggerLabel,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      outcome: outcome ?? this.outcome,
      followUpDone: followUpDone ?? this.followUpDone,
      chosenAlternative: chosenAlternative ?? this.chosenAlternative,
      synced: synced ?? this.synced,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'trigger_label': triggerLabel,
        'intensity': intensity,
        'notes': notes,
        'outcome': outcome.storage,
        'follow_up_done': followUpDone ? 1 : 0,
        'chosen_alternative': chosenAlternative,
        'synced': synced ? 1 : 0,
      };

  factory TriggerLogModel.fromMap(Map<String, Object?> map) {
    return TriggerLogModel(
      id: map['id']! as String,
      userId: map['user_id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      triggerLabel: map['trigger_label'] as String?,
      intensity: map['intensity'] as int?,
      notes: map['notes'] as String?,
      outcome: UrgeOutcomeX.fromStorage(map['outcome'] as String?),
      followUpDone: (map['follow_up_done'] as int? ?? 0) == 1,
      chosenAlternative: map['chosen_alternative'] as String?,
      synced: (map['synced'] as int? ?? 0) == 1,
    );
  }

  Map<String, Object?> toFirestore() => {
        'createdAt': createdAt.toIso8601String(),
        'triggerLabel': triggerLabel,
        'intensity': intensity,
        'notes': notes,
        'outcome': outcome.storage,
        'followUpDone': followUpDone,
        'chosenAlternative': chosenAlternative,
      };
}
