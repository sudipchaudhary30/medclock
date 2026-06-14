enum DoseStatus { taken, missed, skipped }
enum MissedReason { forgot, asleep, sideEffect, other }

class DoseLogModel {
  final String id;
  final String userId;
  final String medicationId;
  final String? reminderId;
  final String? familyMemberId;
  final DoseStatus status;
  final DateTime? confirmedAt;
  final DateTime scheduledAt;
  final String? photoUrl;
  final MissedReason? missedReason;
  final String? missedNote;
  final String? confirmedBy;
  final bool syncedToServer;
  final DateTime createdAt;

  DoseLogModel({
    required this.id,
    required this.userId,
    required this.medicationId,
    this.reminderId,
    this.familyMemberId,
    required this.status,
    this.confirmedAt,
    required this.scheduledAt,
    this.photoUrl,
    this.missedReason,
    this.missedNote,
    this.confirmedBy,
    this.syncedToServer = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DoseLogModel.fromJson(Map<String, dynamic> json) {
    return DoseLogModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      medicationId: json['medicationId'] ?? '',
      reminderId: json['reminderId'],
      familyMemberId: json['familyMemberId'],
      status: _parseStatus(json['status']),
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      scheduledAt: json['scheduledAt'] != null
          ? DateTime.parse(json['scheduledAt'])
          : DateTime.now(),
      photoUrl: json['photoUrl'],
      missedReason: _parseMissedReason(json['missedReason']),
      missedNote: json['missedNote'],
      confirmedBy: json['confirmedBy'],
      syncedToServer: json['syncedToServer'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static DoseStatus _parseStatus(String? status) {
    switch (status) {
      case 'missed':
        return DoseStatus.missed;
      case 'skipped':
        return DoseStatus.skipped;
      default:
        return DoseStatus.taken;
    }
  }

  static MissedReason? _parseMissedReason(String? reason) {
    switch (reason) {
      case 'forgot':
        return MissedReason.forgot;
      case 'asleep':
        return MissedReason.asleep;
      case 'side_effect':
        return MissedReason.sideEffect;
      case 'other':
        return MissedReason.other;
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medicationId': medicationId,
      'reminderId': reminderId,
      'familyMemberId': familyMemberId,
      'status': status.name,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'scheduledAt': scheduledAt.toIso8601String(),
      'photoUrl': photoUrl,
      'missedReason': _missedReasonToString(missedReason),
      'missedNote': missedNote,
      'confirmedBy': confirmedBy,
      'syncedToServer': syncedToServer,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String? _missedReasonToString(MissedReason? reason) {
    switch (reason) {
      case MissedReason.forgot:
        return 'forgot';
      case MissedReason.asleep:
        return 'asleep';
      case MissedReason.sideEffect:
        return 'side_effect';
      case MissedReason.other:
        return 'other';
      default:
        return null;
    }
  }

  DoseLogModel copyWith({
    String? id,
    String? userId,
    String? medicationId,
    String? reminderId,
    String? familyMemberId,
    DoseStatus? status,
    DateTime? confirmedAt,
    DateTime? scheduledAt,
    String? photoUrl,
    MissedReason? missedReason,
    String? missedNote,
    String? confirmedBy,
    bool? syncedToServer,
  }) {
    return DoseLogModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationId: medicationId ?? this.medicationId,
      reminderId: reminderId ?? this.reminderId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      status: status ?? this.status,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      photoUrl: photoUrl ?? this.photoUrl,
      missedReason: missedReason ?? this.missedReason,
      missedNote: missedNote ?? this.missedNote,
      confirmedBy: confirmedBy ?? this.confirmedBy,
      syncedToServer: syncedToServer ?? this.syncedToServer,
      createdAt: createdAt,
    );
  }

  bool get isTaken => status == DoseStatus.taken;
  bool get isMissed => status == DoseStatus.missed;
  bool get isSkipped => status == DoseStatus.skipped;
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}
