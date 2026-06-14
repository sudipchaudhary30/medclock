enum RefillStatus { pending, ordered, shipped, delivered }

class RefillModel {
  final String id;
  final String userId;
  final String medicationId;
  final RefillStatus status;
  final DateTime? triggeredAt;
  final DateTime? orderedAt;
  final String? pharmacyId;
  final bool isAutoOrder;
  final bool isUrgent;
  final double? estimatedCost;
  final String? deliveryId;
  final DateTime createdAt;

  RefillModel({
    required this.id,
    required this.userId,
    required this.medicationId,
    this.status = RefillStatus.pending,
    this.triggeredAt,
    this.orderedAt,
    this.pharmacyId,
    this.isAutoOrder = false,
    this.isUrgent = false,
    this.estimatedCost,
    this.deliveryId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory RefillModel.fromJson(Map<String, dynamic> json) {
    return RefillModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      medicationId: json['medicationId'] ?? '',
      status: _parseStatus(json['status']),
      triggeredAt: json['triggeredAt'] != null
          ? DateTime.parse(json['triggeredAt'])
          : null,
      orderedAt:
          json['orderedAt'] != null ? DateTime.parse(json['orderedAt']) : null,
      pharmacyId: json['pharmacyId'],
      isAutoOrder: json['isAutoOrder'] ?? false,
      isUrgent: json['isUrgent'] ?? false,
      estimatedCost: (json['estimatedCost'] ?? 0).toDouble(),
      deliveryId: json['deliveryId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static RefillStatus _parseStatus(String? status) {
    switch (status) {
      case 'ordered':
        return RefillStatus.ordered;
      case 'shipped':
        return RefillStatus.shipped;
      case 'delivered':
        return RefillStatus.delivered;
      default:
        return RefillStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'medicationId': medicationId,
      'status': status.name,
      'triggeredAt': triggeredAt?.toIso8601String(),
      'orderedAt': orderedAt?.toIso8601String(),
      'pharmacyId': pharmacyId,
      'isAutoOrder': isAutoOrder,
      'isUrgent': isUrgent,
      'estimatedCost': estimatedCost,
      'deliveryId': deliveryId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  RefillModel copyWith({
    RefillStatus? status,
    DateTime? orderedAt,
    String? deliveryId,
    bool? isUrgent,
  }) {
    return RefillModel(
      id: id,
      userId: userId,
      medicationId: medicationId,
      status: status ?? this.status,
      triggeredAt: triggeredAt,
      orderedAt: orderedAt ?? this.orderedAt,
      pharmacyId: pharmacyId,
      isAutoOrder: isAutoOrder,
      isUrgent: isUrgent ?? this.isUrgent,
      estimatedCost: estimatedCost,
      deliveryId: deliveryId ?? this.deliveryId,
      createdAt: createdAt,
    );
  }
}
