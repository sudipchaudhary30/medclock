enum NotificationType {
  doseConfirmed,
  doseMissed,
  dailySummary,
  refillAlert,
  deliveryUpdate,
}

class NotificationModel {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? photoUrl;
  final bool isRead;
  final bool isQueued;
  final DateTime? scheduledDeliveryAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.photoUrl,
    this.isRead = false,
    this.isQueued = false,
    this.scheduledDeliveryAt,
    this.sentAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? json['id'] ?? '',
      recipientId: json['recipientId'] ?? '',
      type: _parseType(json['type']),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'],
      photoUrl: json['photoUrl'],
      isRead: json['isRead'] ?? false,
      isQueued: json['isQueued'] ?? false,
      scheduledDeliveryAt: json['scheduledDeliveryAt'] != null
          ? DateTime.parse(json['scheduledDeliveryAt'])
          : null,
      sentAt: json['sentAt'] != null ? DateTime.parse(json['sentAt']) : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static NotificationType _parseType(String? type) {
    switch (type) {
      case 'dose_confirmed':
        return NotificationType.doseConfirmed;
      case 'dose_missed':
        return NotificationType.doseMissed;
      case 'daily_summary':
        return NotificationType.dailySummary;
      case 'refill_alert':
        return NotificationType.refillAlert;
      case 'delivery_update':
        return NotificationType.deliveryUpdate;
      default:
        return NotificationType.doseConfirmed;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientId': recipientId,
      'type': type.name,
      'title': title,
      'body': body,
      'data': data,
      'photoUrl': photoUrl,
      'isRead': isRead,
      'isQueued': isQueued,
      'scheduledDeliveryAt': scheduledDeliveryAt?.toIso8601String(),
      'sentAt': sentAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    bool? isRead,
    bool? isQueued,
    DateTime? sentAt,
  }) {
    return NotificationModel(
      id: id,
      recipientId: recipientId,
      type: type,
      title: title,
      body: body,
      data: data,
      photoUrl: photoUrl,
      isRead: isRead ?? this.isRead,
      isQueued: isQueued ?? this.isQueued,
      scheduledDeliveryAt: scheduledDeliveryAt,
      sentAt: sentAt ?? this.sentAt,
      createdAt: createdAt,
    );
  }
}
