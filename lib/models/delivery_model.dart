enum DeliveryStatus { processing, dispatched, inTransit, delivered, failed }

class DeliveryModel {
  final String id;
  final String userId;
  final String refillId;
  final DeliveryStatus status;
  final String? courierName;
  final String? trackingNumber;
  final String? deliveryAddress;
  final double? latitude;
  final double? longitude;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final bool isUrgent;
  final DateTime createdAt;

  DeliveryModel({
    required this.id,
    required this.userId,
    required this.refillId,
    this.status = DeliveryStatus.processing,
    this.courierName,
    this.trackingNumber,
    this.deliveryAddress,
    this.latitude,
    this.longitude,
    this.estimatedDelivery,
    this.deliveredAt,
    this.isUrgent = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      refillId: json['refillId'] ?? '',
      status: _parseStatus(json['status']),
      courierName: json['courierName'],
      trackingNumber: json['trackingNumber'],
      deliveryAddress: json['deliveryAddress'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.parse(json['estimatedDelivery'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      isUrgent: json['isUrgent'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  static DeliveryStatus _parseStatus(String? status) {
    switch (status) {
      case 'dispatched':
        return DeliveryStatus.dispatched;
      case 'in_transit':
        return DeliveryStatus.inTransit;
      case 'delivered':
        return DeliveryStatus.delivered;
      case 'failed':
        return DeliveryStatus.failed;
      default:
        return DeliveryStatus.processing;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'refillId': refillId,
      'status': status.name,
      'courierName': courierName,
      'trackingNumber': trackingNumber,
      'deliveryAddress': deliveryAddress,
      'latitude': latitude,
      'longitude': longitude,
      'estimatedDelivery': estimatedDelivery?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'isUrgent': isUrgent,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  DeliveryModel copyWith({
    DeliveryStatus? status,
    double? latitude,
    double? longitude,
    DateTime? deliveredAt,
  }) {
    return DeliveryModel(
      id: id,
      userId: userId,
      refillId: refillId,
      status: status ?? this.status,
      courierName: courierName,
      trackingNumber: trackingNumber,
      deliveryAddress: deliveryAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      estimatedDelivery: estimatedDelivery,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      isUrgent: isUrgent,
      createdAt: createdAt,
    );
  }

  bool get isDelivered => status == DeliveryStatus.delivered;
  bool get isInTransit => status == DeliveryStatus.inTransit;
}
