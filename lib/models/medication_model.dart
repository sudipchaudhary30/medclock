class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String form; // tablet, capsule, inhaler, liquid, injection
  final String? pillPhotoUrl;
  final String? color;
  final String? shape;
  final String? instructions;
  final int totalSupply;
  final int currentSupply;
  final int refillThreshold;
  final bool autoRefill;
  final String? pharmacyId;
  final List<String> similarMedicationIds;
  final bool isActive;
  final DateTime createdAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    this.form = 'tablet',
    this.pillPhotoUrl,
    this.color,
    this.shape,
    this.instructions,
    this.totalSupply = 0,
    this.currentSupply = 0,
    this.refillThreshold = 7,
    this.autoRefill = false,
    this.pharmacyId,
    this.similarMedicationIds = const [],
    this.isActive = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      dosage: json['dosage'] ?? '',
      form: json['form'] ?? 'tablet',
      pillPhotoUrl: json['pillPhotoUrl'],
      color: json['color'],
      shape: json['shape'],
      instructions: json['instructions'],
      totalSupply: json['totalSupply'] ?? 0,
      currentSupply: json['currentSupply'] ?? 0,
      refillThreshold: json['refillThreshold'] ?? 7,
      autoRefill: json['autoRefill'] ?? false,
      pharmacyId: json['pharmacyId'],
      similarMedicationIds:
          List<String>.from(json['similarMedications'] ?? []),
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'dosage': dosage,
      'form': form,
      'pillPhotoUrl': pillPhotoUrl,
      'color': color,
      'shape': shape,
      'instructions': instructions,
      'totalSupply': totalSupply,
      'currentSupply': currentSupply,
      'refillThreshold': refillThreshold,
      'autoRefill': autoRefill,
      'pharmacyId': pharmacyId,
      'similarMedications': similarMedicationIds,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MedicationModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? dosage,
    String? form,
    String? pillPhotoUrl,
    String? color,
    String? shape,
    String? instructions,
    int? totalSupply,
    int? currentSupply,
    int? refillThreshold,
    bool? autoRefill,
    String? pharmacyId,
    List<String>? similarMedicationIds,
    bool? isActive,
  }) {
    return MedicationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      pillPhotoUrl: pillPhotoUrl ?? this.pillPhotoUrl,
      color: color ?? this.color,
      shape: shape ?? this.shape,
      instructions: instructions ?? this.instructions,
      totalSupply: totalSupply ?? this.totalSupply,
      currentSupply: currentSupply ?? this.currentSupply,
      refillThreshold: refillThreshold ?? this.refillThreshold,
      autoRefill: autoRefill ?? this.autoRefill,
      pharmacyId: pharmacyId ?? this.pharmacyId,
      similarMedicationIds: similarMedicationIds ?? this.similarMedicationIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  /// Days of supply remaining based on doses per day
  int daysRemaining(int dosesPerDay) {
    if (dosesPerDay <= 0) return currentSupply;
    return (currentSupply / dosesPerDay).floor();
  }

  /// Whether supply is at or below refill threshold
  bool needsRefill(int dosesPerDay) {
    return daysRemaining(dosesPerDay) <= refillThreshold;
  }

  /// Whether supply is critically low (3 days or less)
  bool isCriticallyLow(int dosesPerDay) {
    return daysRemaining(dosesPerDay) <= 3;
  }

  bool get hasSimilarMedications => similarMedicationIds.isNotEmpty;
  bool get hasPhoto => pillPhotoUrl != null && pillPhotoUrl!.isNotEmpty;
}
