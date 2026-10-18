import 'package:flutter/foundation.dart';

/// Persisted user profile domain model with stable ID, createdAt, and updatedAt.
@immutable
class UserProfile {
  UserProfile({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.fullName,
    this.username,
    this.email,
    this.phone,
    this.homeCity,
    this.dob,
    this.avatarPath,
    this.ridingTier = 'ADV PRO',
    this.experienceIndex = 2,
    Set<String>? ridingStyles,
    this.unitIndex = 0,
    this.emergencyContactName,
    this.emergencyContactRelation,
    this.emergencyContactPhone,
    this.bloodGroup = 'O+ (Universal Donor)',
  })  : id = id ?? 'profile-default',
        createdAt = (createdAt ?? DateTime.now()).toUtc(),
        updatedAt = (updatedAt ?? DateTime.now()).toUtc(),
        ridingStyles = ridingStyles ?? const {'Touring'};

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final created = parseUtc(json['createdAt']) ?? DateTime.now().toUtc();
    final updated = parseUtc(json['updatedAt']) ?? created;

    Set<String> styles = {'Touring'};
    if (json['ridingStyles'] is List) {
      styles = (json['ridingStyles'] as List).cast<String>().toSet();
    }

    return UserProfile(
      id: json['id'] as String? ?? 'profile-default',
      createdAt: created,
      updatedAt: updated,
      fullName: json['fullName'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      homeCity: json['homeCity'] as String?,
      dob: json['dob'] as String?,
      avatarPath: json['avatarPath'] as String?,
      ridingTier: json['ridingTier'] as String? ?? 'ADV PRO',
      experienceIndex: (json['experienceIndex'] as num?)?.toInt() ?? 2,
      ridingStyles: styles,
      unitIndex: (json['unitIndex'] as num?)?.toInt() ?? 0,
      emergencyContactName: json['emergencyContactName'] as String?,
      emergencyContactRelation: json['emergencyContactRelation'] as String?,
      emergencyContactPhone: json['emergencyContactPhone'] as String?,
      bloodGroup: json['bloodGroup'] as String? ?? 'O+ (Universal Donor)',
    );
  }

  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get effectiveId => id;
  DateTime get effectiveCreatedAt => createdAt;
  DateTime get effectiveUpdatedAt => updatedAt;

  final String? fullName;
  final String? username;
  final String? email;
  final String? phone;
  final String? homeCity;
  final String? dob;
  final String? avatarPath;
  final String ridingTier;
  final int experienceIndex;
  final Set<String> ridingStyles;
  final int unitIndex;

  final String? emergencyContactName;
  final String? emergencyContactRelation;
  final String? emergencyContactPhone;
  final String bloodGroup;

  UserProfile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? fullName,
    String? username,
    String? email,
    String? phone,
    String? homeCity,
    String? dob,
    String? avatarPath,
    String? ridingTier,
    int? experienceIndex,
    Set<String>? ridingStyles,
    int? unitIndex,
    String? emergencyContactName,
    String? emergencyContactRelation,
    String? emergencyContactPhone,
    String? bloodGroup,
  }) {
    return UserProfile(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      homeCity: homeCity ?? this.homeCity,
      dob: dob ?? this.dob,
      avatarPath: avatarPath ?? this.avatarPath,
      ridingTier: ridingTier ?? this.ridingTier,
      experienceIndex: experienceIndex ?? this.experienceIndex,
      ridingStyles: ridingStyles ?? this.ridingStyles,
      unitIndex: unitIndex ?? this.unitIndex,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactRelation:
          emergencyContactRelation ?? this.emergencyContactRelation,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toUtc().toIso8601String(),
        'updatedAt': updatedAt.toUtc().toIso8601String(),
        'fullName': fullName,
        'username': username,
        'email': email,
        'phone': phone,
        'homeCity': homeCity,
        'dob': dob,
        'avatarPath': avatarPath,
        'ridingTier': ridingTier,
        'experienceIndex': experienceIndex,
        'ridingStyles': ridingStyles.toList(),
        'unitIndex': unitIndex,
        'emergencyContactName': emergencyContactName,
        'emergencyContactRelation': emergencyContactRelation,
        'emergencyContactPhone': emergencyContactPhone,
        'bloodGroup': bloodGroup,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          username == other.username &&
          email == other.email &&
          phone == other.phone &&
          homeCity == other.homeCity &&
          dob == other.dob &&
          avatarPath == other.avatarPath &&
          ridingTier == other.ridingTier &&
          experienceIndex == other.experienceIndex &&
          setEquals(ridingStyles, other.ridingStyles) &&
          unitIndex == other.unitIndex &&
          emergencyContactName == other.emergencyContactName &&
          emergencyContactRelation == other.emergencyContactRelation &&
          emergencyContactPhone == other.emergencyContactPhone &&
          bloodGroup == other.bloodGroup;

  @override
  int get hashCode => Object.hash(
        id,
        fullName,
        username,
        email,
        phone,
        homeCity,
        dob,
        avatarPath,
        ridingTier,
        experienceIndex,
        Object.hashAll(ridingStyles),
        unitIndex,
        emergencyContactName,
        emergencyContactRelation,
        emergencyContactPhone,
        bloodGroup,
      );
}
