enum UserRole { patient, caregiver }

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? photoBase64;
  final UserRole role;
  final List<String> linkedUserIds;
  final String? familyGroupId;
  final List<String> fcmTokens;
  final UserSettings settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.photoBase64,
    required this.role,
    this.linkedUserIds = const [],
    this.familyGroupId,
    this.fcmTokens = const [],
    UserSettings? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : settings = settings ?? UserSettings(),
       createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'],
      photoBase64: json['photoBase64'],
      role: json['role'] == 'caregiver' ? UserRole.caregiver : UserRole.patient,
      linkedUserIds: List<String>.from(json['linkedUsers'] ?? []),
      familyGroupId: json['familyGroupId'],
      fcmTokens: List<String>.from(json['fcmTokens'] ?? []),
      settings: json['settings'] != null
          ? UserSettings.fromJson(json['settings'])
          : UserSettings(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'role': role == UserRole.caregiver ? 'caregiver' : 'patient',
      'linkedUsers': linkedUserIds,
      'familyGroupId': familyGroupId,
      'fcmTokens': fcmTokens,
      'photoBase64': photoBase64,
      'settings': settings.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? photoBase64,
    UserRole? role,
    List<String>? linkedUserIds,
    String? familyGroupId,
    List<String>? fcmTokens,
    UserSettings? settings,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoBase64: photoBase64 ?? this.photoBase64,
      role: role ?? this.role,
      linkedUserIds: linkedUserIds ?? this.linkedUserIds,
      familyGroupId: familyGroupId ?? this.familyGroupId,
      fcmTokens: fcmTokens ?? this.fcmTokens,
      settings: settings ?? this.settings,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  bool get isCaregiver => role == UserRole.caregiver;
  bool get isPatient => role == UserRole.patient;
}

class UserSettings {
  final double fontSize;
  final String quietHoursStart;
  final String quietHoursEnd;
  final String? reminderSound;
  final double reminderVolume;
  final bool isDarkMode;

  UserSettings({
    this.fontSize = 16.0,
    this.quietHoursStart = '23:00',
    this.quietHoursEnd = '07:00',
    this.reminderSound,
    this.reminderVolume = 1.0,
    this.isDarkMode = false,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      fontSize: (json['fontSize'] ?? 16.0).toDouble(),
      quietHoursStart: json['quietHoursStart'] ?? '23:00',
      quietHoursEnd: json['quietHoursEnd'] ?? '07:00',
      reminderSound: json['reminderSound'],
      reminderVolume: (json['reminderVolume'] ?? 1.0).toDouble(),
      isDarkMode: json['isDarkMode'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fontSize': fontSize,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'reminderSound': reminderSound,
      'reminderVolume': reminderVolume,
      'isDarkMode': isDarkMode,
    };
  }

  UserSettings copyWith({
    double? fontSize,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? reminderSound,
    double? reminderVolume,
    bool? isDarkMode,
  }) {
    return UserSettings(
      fontSize: fontSize ?? this.fontSize,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      reminderSound: reminderSound ?? this.reminderSound,
      reminderVolume: reminderVolume ?? this.reminderVolume,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }
}
