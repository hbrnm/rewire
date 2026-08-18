class UserModel {
  const UserModel({
    required this.id,
    required this.createdAt,
    this.incognitoMode = false,
    this.notificationsEnabled = true,
    this.checkInHour,
    this.displayName,
    this.lastSyncedAt,
  });

  final String id;
  final DateTime createdAt;
  final bool incognitoMode;
  final bool notificationsEnabled;
  final int? checkInHour;
  final String? displayName;
  final DateTime? lastSyncedAt;

  UserModel copyWith({
    String? id,
    DateTime? createdAt,
    bool? incognitoMode,
    bool? notificationsEnabled,
    int? checkInHour,
    bool clearCheckInHour = false,
    String? displayName,
    DateTime? lastSyncedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      checkInHour: clearCheckInHour ? null : (checkInHour ?? this.checkInHour),
      displayName: displayName ?? this.displayName,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, Object?> toMap() => {
        'id': id,
        'created_at': createdAt.millisecondsSinceEpoch,
        'incognito_mode': incognitoMode ? 1 : 0,
        'notifications_enabled': notificationsEnabled ? 1 : 0,
        'check_in_hour': checkInHour,
        'display_name': displayName,
        'last_synced_at': lastSyncedAt?.millisecondsSinceEpoch,
      };

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: map['id']! as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']! as int),
      incognitoMode: (map['incognito_mode'] as int? ?? 0) == 1,
      notificationsEnabled: (map['notifications_enabled'] as int? ?? 1) == 1,
      checkInHour: map['check_in_hour'] as int?,
      displayName: map['display_name'] as String?,
      lastSyncedAt: map['last_synced_at'] == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(map['last_synced_at']! as int),
    );
  }

  Map<String, Object?> toFirestore() => {
        'createdAt': createdAt.toIso8601String(),
        'incognitoMode': incognitoMode,
        'notificationsEnabled': notificationsEnabled,
        'checkInHour': checkInHour,
        'displayName': displayName,
      };
}
