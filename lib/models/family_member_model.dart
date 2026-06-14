import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class FamilyMemberModel {
  final String id;
  final String userId;
  final String name;
  final String colorHex;
  final String role; // patient or caregiver
  final DateTime addedAt;

  FamilyMemberModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.colorHex,
    this.role = 'patient',
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      colorHex: json['color'] ?? '#2D7DD2',
      role: json['role'] ?? 'patient',
      addedAt: json['addedAt'] != null
          ? DateTime.parse(json['addedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'color': colorHex,
      'role': role,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  FamilyMemberModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? colorHex,
    String? role,
  }) {
    return FamilyMemberModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      role: role ?? this.role,
      addedAt: addedAt,
    );
  }

  Color get color {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppTheme.primaryColor;
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class FamilyGroupModel {
  final String id;
  final String name;
  final String createdBy;
  final List<FamilyMemberModel> members;
  final DateTime createdAt;

  FamilyGroupModel({
    required this.id,
    required this.name,
    required this.createdBy,
    this.members = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory FamilyGroupModel.fromJson(Map<String, dynamic> json) {
    return FamilyGroupModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      createdBy: json['createdBy'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => FamilyMemberModel.fromJson(m))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'members': members.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
