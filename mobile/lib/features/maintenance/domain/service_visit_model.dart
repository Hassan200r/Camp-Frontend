import 'package:flutter/material.dart';

import 'trip_budget_model.dart';

/// Domain model representing a planned or historical motorcycle workshop/mechanic service visit.
@immutable
class ServiceVisit {
  const ServiceVisit({
    required this.id,
    required this.dateTime,
    required this.shopName,
    this.bikeId,
    this.cost,
    this.expenseId,
    this.phone,
    this.latitude,
    this.longitude,
    this.note,
    this.mechanicId,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceVisit.fromJson(Map<String, dynamic> json) {
    DateTime? parseUtc(dynamic val) {
      if (val == null) return null;
      if (val is String) return DateTime.tryParse(val)?.toUtc();
      return null;
    }

    final rawId = json['id'] as String?;
    final effectiveId = (rawId != null && rawId.trim().isNotEmpty)
        ? rawId.trim()
        : 'visit-${DateTime.now().millisecondsSinceEpoch}';

    final parsedDt = DateTime.tryParse(json['dateTime'] as String? ?? '') ??
        DateTime.now().add(const Duration(days: 7));
    final createdUtc = parseUtc(json['createdAt']) ?? DateTime.now().toUtc();
    final updatedUtc = parseUtc(json['updatedAt']) ?? createdUtc;

    final phoneStr = (json['phone'] ?? json['phoneNumber']) as String?;
    final lat = (json['latitude'] as num?)?.toDouble();
    final lng = (json['longitude'] as num?)?.toDouble();
    final costVal = (json['cost'] as num?)?.toDouble();
    final rawExpId = (json['expenseId'] ?? json['expense_id']) as String?;

    return ServiceVisit(
      id: effectiveId,
      dateTime: parsedDt,
      shopName: json['shopName'] as String? ?? 'Motorcycle Workshop',
      bikeId: json['bikeId'] as String?,
      cost: costVal,
      expenseId: (rawExpId != null && rawExpId.trim().isNotEmpty)
          ? rawExpId.trim()
          : null,
      phone: (phoneStr != null && phoneStr.trim().isNotEmpty)
          ? phoneStr.trim()
          : null,
      latitude: lat,
      longitude: lng,
      note: json['note'] as String?,
      mechanicId: json['mechanicId'] as String?,
      createdAt: createdUtc,
      updatedAt: updatedUtc,
    );
  }

  final String id;
  final String? bikeId;
  final double? cost;
  final String? expenseId;
  final DateTime dateTime;
  final String shopName;
  final String? phone;
  final double? latitude;
  final double? longitude;
  final String? note;
  final String? mechanicId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  String get effectiveId => id;
  DateTime get effectiveCreatedAt =>
      createdAt?.toUtc() ?? DateTime(2024, 1, 1).toUtc();
  DateTime get effectiveUpdatedAt =>
      updatedAt?.toUtc() ?? effectiveCreatedAt;

  /// True if the visit's scheduled date/time has already passed.
  bool get isPast => dateTime.isBefore(DateTime.now());

  /// True if phone number is available for direct calling.
  bool get hasPhone => phone != null && phone!.trim().isNotEmpty;

  /// True if valid geographic coordinates are stored for navigation.
  bool get hasCoordinates => latitude != null && longitude != null;

  /// Human-readable date and time e.g. "Oct 24, 2026 • 10:00 AM".
  String get formattedDateTime {
    final dateStr = formatTripDate(dateTime);
    final hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final standardHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$dateStr • $standardHour:$minute $period';
  }

  static const _sentinel = Object();

  ServiceVisit copyWith({
    String? id,
    DateTime? dateTime,
    String? shopName,
    Object? bikeId = _sentinel,
    Object? cost = _sentinel,
    Object? expenseId = _sentinel,
    String? phone,
    double? latitude,
    double? longitude,
    String? note,
    String? mechanicId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ServiceVisit(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      shopName: shopName ?? this.shopName,
      bikeId: identical(bikeId, _sentinel) ? this.bikeId : (bikeId as String?),
      cost: identical(cost, _sentinel) ? this.cost : (cost as double?),
      expenseId: identical(expenseId, _sentinel)
          ? this.expenseId
          : (expenseId as String?),
      phone: phone ?? this.phone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      note: note ?? this.note,
      mechanicId: mechanicId ?? this.mechanicId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now().toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'shopName': shopName,
      'bikeId': bikeId,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'note': note,
      'mechanicId': mechanicId,
      'createdAt': effectiveCreatedAt.toIso8601String(),
      'updatedAt': effectiveUpdatedAt.toIso8601String(),
    };
    if (cost != null) map['cost'] = cost;
    if (expenseId != null) map['expenseId'] = expenseId;
    return map;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceVisit &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          dateTime == other.dateTime &&
          shopName == other.shopName &&
          bikeId == other.bikeId &&
          cost == other.cost &&
          expenseId == other.expenseId &&
          phone == other.phone &&
          note == other.note;

  @override
  int get hashCode => Object.hash(
        id,
        dateTime,
        shopName,
        bikeId,
        cost,
        expenseId,
        phone,
        note,
      );
}
