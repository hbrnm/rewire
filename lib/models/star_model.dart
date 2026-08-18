class StarModel {
  const StarModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    this.sourceLogId,
  });

  final String id;
  final String userId;
  final DateTime createdAt;
  final String? sourceLogId;

  Map<String, Object?> toMap() => {
        'id': id,
        'user_id': userId,
        'created_at': createdAt.millisecondsSinceEpoch,
        'source_log_id': sourceLogId,
      };

  factory StarModel.fromMap(Map<String, Object?> map) {
    return StarModel(
      id: map['id']! as String,
      userId: map['user_id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      sourceLogId: map['source_log_id'] as String?,
    );
  }
}
