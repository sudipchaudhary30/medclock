enum ReminderStatus { active, snoozed, fired, dismissed }

class ReminderModel {
  final String id;
  final String userId;
  final String medicationId;
  final String? familyMemberId;
  final String scheduledTime; // "HH:mm"
  final List<String> days; // ["Mon","Tue",...]
  final bool isRelativeToShift;
  final int? shiftOffset; // minutes from shift start
  final bool calendarAware;
  final int maxSnoozeCount;
  final int currentSnoozeCount;
  final ReminderStatus status;
  final bool isOfflineCapable;
  final bool adaptiveEnabled;
  final int lateCount;
  final DateTime createdAt;

  ReminderModel({
    required this.id,
    required this.userId,
    required this.medicationId,
    this.familyMemberId,
    required this.scheduledTime,
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    this.isRelativeToShift = false,
    this.shiftOffset,
    this.calendarAware = false,
    this.maxSnoozeCount = 2,
    this.currentSnoozeCount = 0,
    this.status = ReminderStatus.active,
    this.isOfflineCapable = true,
    this.adaptiveEnabled = false,
    this.lateCount = 0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      medicationId: json['medicationId'] ?? '',
      familyMemberId: json['familyMemberId'],
      scheduledTime: json['scheduledTime'] ?? '08:00',
      days: List<String>.from(json['days'] ?? []),
      isRelativeToShift: json['isRelativeToShift'] ?? false,
      shiftOffset: json['shiftOffset'],
      calendarAware: json['calendarAware'] ?? false,
      maxSnoozeCount: json['maxSnoozeCount'] ?? 2,
      currentSnoozeCount: json['currentSnoozeCount'] ?? 0,
      status: _parseStatus(json['status']),
      isOfflineCapable: json['isOfflineCapable'] ?? true,
      adaptiveEnabled: json['adaptiveEnabled'] ?? false,
      lateCount: json['lateCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static ReminderStatus _parseStatus(String? status) {
    switch (status) {
      case 'snoozed':
        return ReminderStatus.snoozed;
      case 'fired':
        return ReminderStatus.fired;
      case 'dismissed':
        return ReminderStatus.dismissed;
      default:
        return ReminderStatus.active;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medicationId': medicationId,
      'familyMemberId': familyMemberId,
      'scheduledTime': scheduledTime,
      'days': days,
      'isRelativeToShift': isRelativeToShift,
      'shiftOffset': shiftOffset,
      'calendarAware': calendarAware,
      'maxSnoozeCount': maxSnoozeCount,
      'currentSnoozeCount': currentSnoozeCount,
      'status': status.name,
      'isOfflineCapable': isOfflineCapable,
      'adaptiveEnabled': adaptiveEnabled,
      'lateCount': lateCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  ReminderModel copyWith({
    String? id,
    String? userId,
    String? medicationId,
    String? familyMemberId,
    String? scheduledTime,
    List<String>? days,
    bool? isRelativeToShift,
    int? shiftOffset,
    bool? calendarAware,
    int? maxSnoozeCount,
    int? currentSnoozeCount,
    ReminderStatus? status,
    bool? isOfflineCapable,
    bool? adaptiveEnabled,
    int? lateCount,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      medicationId: medicationId ?? this.medicationId,
      familyMemberId: familyMemberId ?? this.familyMemberId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      days: days ?? this.days,
      isRelativeToShift: isRelativeToShift ?? this.isRelativeToShift,
      shiftOffset: shiftOffset ?? this.shiftOffset,
      calendarAware: calendarAware ?? this.calendarAware,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      currentSnoozeCount: currentSnoozeCount ?? this.currentSnoozeCount,
      status: status ?? this.status,
      isOfflineCapable: isOfflineCapable ?? this.isOfflineCapable,
      adaptiveEnabled: adaptiveEnabled ?? this.adaptiveEnabled,
      lateCount: lateCount ?? this.lateCount,
      createdAt: createdAt,
    );
  }

  bool get canSnooze => currentSnoozeCount < maxSnoozeCount;
  bool get isSnoozed => status == ReminderStatus.snoozed;
  bool get isActive => status == ReminderStatus.active;

  /// Parse scheduled time to TimeOfDay
  TimeOfDay get timeOfDay {
    final parts = scheduledTime.split(':');
    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  String format() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String formatAmPm() {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
