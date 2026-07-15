/// Represents a calculated adherence summary for a user over a given period.
class AdherenceModel {
  final String userId;
  final int periodDays;
  final int takenCount;
  final int missedCount;
  final int skippedCount;
  final int totalScheduled;

  /// Adherence rate as a percentage 0-100.
  final double adherenceRate;

  final DateTime calculatedAt;

  const AdherenceModel({
    required this.userId,
    required this.periodDays,
    required this.takenCount,
    required this.missedCount,
    required this.skippedCount,
    required this.totalScheduled,
    required this.adherenceRate,
    required this.calculatedAt,
  });

  /// Zero-value adherence (no data available).
  factory AdherenceModel.empty(String userId) => AdherenceModel(
        userId: userId,
        periodDays: 30,
        takenCount: 0,
        missedCount: 0,
        skippedCount: 0,
        totalScheduled: 0,
        adherenceRate: 0,
        calculatedAt: DateTime.now(),
      );

  factory AdherenceModel.fromJson(Map<String, dynamic> json) {
    final taken = (json['takenCount'] as num?)?.toInt() ?? 0;
    final missed = (json['missedCount'] as num?)?.toInt() ?? 0;
    final skipped = (json['skippedCount'] as num?)?.toInt() ?? 0;
    final total = (json['totalScheduled'] as num?)?.toInt() ??
        (taken + missed + skipped);
    final rate = json['adherenceRate'] != null
        ? (json['adherenceRate'] as num).toDouble()
        : (total > 0 ? (taken / total) * 100.0 : 0.0);

    return AdherenceModel(
      userId: json['userId'] as String? ?? '',
      periodDays: (json['periodDays'] as num?)?.toInt() ?? 30,
      takenCount: taken,
      missedCount: missed,
      skippedCount: skipped,
      totalScheduled: total,
      adherenceRate: rate,
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'periodDays': periodDays,
        'takenCount': takenCount,
        'missedCount': missedCount,
        'skippedCount': skippedCount,
        'totalScheduled': totalScheduled,
        'adherenceRate': adherenceRate,
        'calculatedAt': calculatedAt.toIso8601String(),
      };

  /// Rounded integer percentage for display (e.g. 87).
  int get adherencePercent => adherenceRate.round().clamp(0, 100);
}
